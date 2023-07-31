#
# GET AND CLEAN FILES
#

# Accesses files from the gdrive folder, cleans them, and saves to goop$processed_df
observe({
  
  raw_folder <- PROCESSED_FOLDER
  list_of_raw_csv_names = drive_ls(raw_folder)[['name']] #gives us file names from google drive
  if(length(list_of_raw_csv_names)<1){
    goop$processed_df <- NULL
    return()
  }

  get_and_clean_data <- function(){
    df = c() #creates an empty vector
    for(i in 1:length(list_of_raw_csv_names)){ #for each name in however many files we have, do the following:
      name <- list_of_raw_csv_names[i] #gets first name
      file <- drive_get(name)[1,] #if there is a csv by this name, get it.
      drive_download(file, path = name, overwrite = TRUE) # downloads a particular file
      loaded = read.csv(name, header=T) #loads file into r environment
      loaded <- loaded %>% mutate(Date_Time = parse_date_time(Date_Time, "%m/%d/%y %I:%M:%S %p"))
      loaded <- loaded %>% mutate(Flag = ifelse(is.na(Flag), 'NA', Flag))
      df[[i]] = loaded #makes the ith element of the list equal to the data frame.
    }
    return(df)
  }
  
  clean_dataframe_list <- get_and_clean_data()
  processed_df <- do.call(rbind, clean_dataframe_list) #combining all data frames - function binding rows
  
  goop$processed_df <- processed_df
})

#
# USER INTERACTION
#

# renderUIs to select site and stations that are present
output$viewSiteStationSelects <- renderUI({
  div(
    selectInput('viewSiteSelect', 'Select Site', unique(goop$processed_df$Site)),
    selectInput('viewStationSelect', 'Select Station', unique(goop$processed_df$Station))
  )
})

# Uses the varViewUI function to display each unique variable within goop$processed_df
output$varViewContainers <- renderUI({
  vars <- unique(goop$processed_df$Variable)
  LL <- vector("list",length(vars))       
  for(i in vars){
    LL[[i]] <- list(varViewUI(id = i, var = i))
  }      
  return(LL)  
})

# Continuously observes changes in the unique variables present in the goop$combined_df data frame.
observe({
  lapply(unique(goop$processed_df$Variable), function(i) {
    varViewServer(id = i, 
                  variable = i, 
                  goop = goop, 
                  dateRange = reactive({input$date_range_input_view}),
                  pickedSite = reactive({input$viewSiteSelect}),
                  pickedStation = reactive({input$viewStationSelect}))
  })
}) 

# A renderUI that allows users to select from the uploaded dates 
output$viewDateRange <- renderUI({
  start_date = min(goop$processed_df$Date_Time)
  end_date = max(goop$processed_df$Date_Time)
  dateRangeInput("date_range_input_view", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date)
})