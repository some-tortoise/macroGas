#
# UI STUFF
#

# renderUIs to select site and stations that are present
output$qaqcSiteStationSelects <- renderUI({
  div(
    selectInput('qaqcSiteSelect', "Select Site", unique(goop$combined_df$Site)),
    selectInput('qaqcStationSelect', 'Select Station', unique(goop$combined_df$Station))
  )
})

# A renderUI that allows users to select from the uploaded dates 
output$qaqcDateRange <- renderUI({
  start_date = min(goop$combined_df$Date_Time)
  end_date = max(goop$combined_df$Date_Time)
  dateRangeInput("date_range_qaqc", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date, min = start_date, max = end_date)
})

#
# UPLOAD AND VIEW
#

# View plots/variable containers based on variable and dataframe changes within uploaded data 
observeEvent(input$uploadBtn, {
  
  # Uses the varViewUI function to display each unique variable within goop$combined_df in it's own plot/container
  output$varContainers <- renderUI({
    vars <- unique(goop$combined_df$Variable)
    LL <- vector("list",length(vars))       
    for(i in vars){
      LL[[i]] <- list(varContainerUI(id = i, var = i))
    }      
    return(LL)  
  }) 
  
  # Continuously observes changes in the unique variables present in the goop$combined_df data frame
  # and updates the containers
  observe({
    lapply(unique(goop$combined_df$Variable), function(i) {
      varContainerServer(id = i, 
                         variable = i, 
                         goop = goop, 
                         dateRange = reactive({input$date_range_qaqc}),
                         pickedSite = reactive({input$qaqcSiteSelect}),
                         pickedStation = reactive({input$qaqcStationSelect}))
    })
  }) 
}) 

#
# SAVE TO GDRIVE
#

# Saving QA/QC'd files to the Google Drive processed folder
observeEvent(input$qaqcSave, {
  file_path <- PROCESSED_FOLDER #file path to the processed google drive folder
  file_name <- "output.csv"
  
  # for loop to upload files to googledrive
  for(site in unique(goop$combined_df$Site)){
    for(station in unique(goop$combined_df$Station)){
      date <- str_split(min(goop$combined_df$Date_Time), pattern = ' ')[[1]][1]
      file_name <- paste0('processed_',site,'_',station,'_',date,'.csv')
      exportDF <- goop$combined_df
      exportDF['Date_Time'] <- format(exportDF['Date_Time'], "%m/%d/%y %I:%M:%S %p")
      write.csv(exportDF, file_name, row.names = FALSE)
      drive_upload(name = file_name, media = file_name, path = file_path)
      file.remove(file_name)
    }
  }
  alert('Files Uploaded!')
})

