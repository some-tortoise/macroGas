templateCSV <- data.frame(
  "Date_Time" = c("5/25/23 13:33:15", "5/25/23 13:33:20", "5/25/23 13:33:25", "5/25/23 13:33:30", "5/25/23 13:33:35", "5/25/23 13:33:40", "5/25/23 13:33:45", "5/25/23 13:33:50", "5/25/23 13:33:55", "5/25/23 13:34:00", "5/25/23 13:34:05", "5/25/23 13:34:10", "5/25/23 13:34:15", "5/25/23 13:34:20", "5/25/23 13:34:25", "5/25/23 13:34:30", "5/25/23 13:34:35", "5/25/23 13:34:40", "5/25/23 13:34:45", "5/25/23 13:34:50", "5/25/23 13:34:55", "5/25/23 13:35:00", "5/25/23 13:35:05", "5/25/23 13:35:10", "5/25/23 13:35:15", "5/25/23 13:35:20", "5/25/23 13:35:25", "5/25/23 13:35:30", "5/25/23 13:35:35", "5/25/23 13:35:40", "5/25/23 13:35:45", "5/25/23 13:35:50", "5/25/23 13:35:55", "5/25/23 13:36:00", "5/25/23 13:36:05", "5/25/23 13:36:10", "5/25/23 13:36:15", "5/25/23 13:36:20", "5/25/23 13:36:25", "5/25/23 13:36:30", "5/25/23 13:36:35", "5/25/23 13:36:40", "5/25/23 13:36:45", "5/25/23 13:36:50", "5/25/23 13:36:55", "5/25/23 13:37:00", "5/25/23 13:37:05", "5/25/23 13:37:10", "5/25/23 13:37:15", "5/25/23 13:37:20", "5/25/23 13:37:25", "5/25/23 13:37:30", "5/25/23 13:37:35", "5/25/23 13:37:40", "5/25/23 13:37:45"),
  "Station" = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
  "Low_Range_μS_cm" = c(125.8, 126.1, 126.4, 126.6, 127.0, 127.2, 127.5, 127.5, 127.7, 127.8, 128.9, 134.3, 153.9, 167.6, 206.2, 270.2, 331.9, 383.4, 417.1, 434.6, 437.6, 428.3, 394.3, 369.6, 335.8, 292.1, 271.6, 235.6, 221.0, 196.0, 185.1, 164.7, 156.8, 143.3, 139.7, 137.6, 134.5, 133.1, 130.9, 129.7, 128.9, 128.6, 128.1, 127.7, 127.5, 127.5, 127.1, 127.1, 126.8, 126.7, 126.6, 126.4, 126.4, 126.4, 126.3),
  "Full_Range_μS_cm" = c(128.8, 129.6, 129.6, 130.3, 130.3, 130.7, 130.7, 130.7, 131.1, 131.1, 132.7, 138.1, 159.8, 174.9, 217.3, 287.3, 355.7, 414.2, 452.2, 472.1, 475.7, 464.5, 426.0, 397.9, 360.4, 312.0, 289.6, 249.7, 233.3, 206.0, 194.0, 171.8, 163.3, 148.5, 144.3, 142.0, 138.9, 136.9, 134.6, 133.1, 132.3, 131.9, 131.5, 130.7, 130.7, 130.7, 130.3, 130.7, 130.3, 130.0, 130.0, 129.6, 129.6, 129.6, 129.6),
  "High_Range_μS_cm" = rep(NA, 55),
  "Temp_C" = c(18.29, 18.27, 18.27, 18.27, 18.27, 18.27, 18.27, 18.29, 18.27, 18.29, 18.29, 18.27, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.30, 18.30, 18.29, 18.29, 18.29, 18.30, 18.30, 18.30, 18.30, 18.29, 18.29, 18.30, 18.30, 18.29, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.29, 18.30, 18.30, 18.30),
  stringsAsFactors = FALSE)
  
dtRendered <- reactiveVal(FALSE)
uploaded_data <- reactiveValues(csv_names = NULL, 
                                  data = NULL,
                                  index = 1,
                                  station_names = NULL,
                                  combined_df = NULL)

# template stuff
output$downloadFile <- downloadHandler( #data template download button
    filename = "slugtemplate.csv",
    content = function(file) {
      write.csv(templateCSV, file, row.names = FALSE)
      })

output$downloadFile <- downloadHandler( #data template download button
  filename = "slugtemplate.csv",
  content = function(file) {
    write.csv(templateCSV, file, row.names = FALSE)
  })


#function for checking whether the format of the uploaded file
check_format <- function(csv_file, file_name){
  if (!identical(colnames(csv_file), colnames(templateCSV))) {
    showModal(modalDialog(
      title = "Error",
      p("Uploaded CSV must have identical columns (same column names and sequence) to the given template.
      If you do not have certain data, please leave that respective column blank."),
      easyClose = FALSE,
      footer = tagList(
        modalButton("Back")
      )
    ))
    return(FALSE)
  } 
  else{
    dtRendered(TRUE)
    if(file_name %in% uploaded_data$csv_names){
      return(TRUE)
    }
    else{
      uploaded_data$data[[length(uploaded_data$data) + 1]] <- csv_file #stores a correctly formatted data in uploaded_data$data as a separate element
      uploaded_data$csv_names <- c(uploaded_data$csv_names, file_name)
      updateSelectInput(session, 'select', choices = uploaded_data$csv_names, selected = file_name)
    }
  }
}

#import data with correct format from gdrive
import_from_drive <- function(gdrive_link) {
  file_id <- sub('.*\\/d\\/([^\\/]+).*', '\\1', gdrive_link)
  if (file_id == gdrive_link) 
    return(NULL)
  file_name = drive_get(as_id(file_id))[["name"]]
  file_type = tail(unlist(strsplit(file_name, "\\.")),n=1)
  if(file_type=="csv"){
    temp_file <- tempfile(fileext = ".csv")
    drive_download(as_id(file_id), path = temp_file)
    tryCatch({data <- read.csv(temp_file)}, error = function(e) data<-NULL)
    unlink(temp_file)
    return(list(data, file_name)) 
  }
  else
    return(NULL)
}

observeEvent(input$import_button, {
  if (!is.null(input$gdrive_link) && input$gdrive_link != "") {
    data <- import_from_drive(input$gdrive_link)[[1]]
    if (!is.null(data)) {
      file_name <- import_from_drive(input$gdrive_link)[[2]]
      check_format(data, file_name)
    } 
    else {
      showModal(
        modalDialog(
          title = "Error",
          "Failed to import data from Google Drive. Please make sure the link is valid and accessible."
        )
      )
    }
  } 
  else {
    showModal(
      modalDialog(
        title = "Error",
        "Please enter a valid Google Drive link."
      )
    )
  }
  
})

#import data from local
# observeEvent(input$upload, {
#   req(input$upload)
#   tryCatch({df = read.csv(input$upload$datapath)}, error = function(e) df=NULL) #using the df value just to check formatting, usin a new variable to save to uploaded_data later
#   check_format(df, input$upload$name)
#   
# })

observeEvent(input$upload, {
  req(input$upload)
  tryCatch(
    {
      for(i in 1:length(input$upload[,1])){
        df <- read.csv(input$upload[[i, 'datapath']])
        fileName <- input$upload[[i, 'name']]
        print(fileName)
        check_format(df, fileName)
      }
      #df = read.csv(input$upload$datapath)
    },
    error = function(e) df=NULL
  ) #using the df value just to check formatting, usin a new variable to save to uploaded_data later

  #   print(df[1])
  # for(fileName in input$upload$name){
  #   check_format(df, fileName)
  # }

})

observe({
  if(length(uploaded_data$csv_names) > 0)
    if(length(uploaded_data$csv_names) > 1){
      for(i in 1:length(uploaded_data$csv_names)){
        if(input$select == uploaded_data$csv_names[i]){
          uploaded_data$index <- i
        }
      } 
    }
    else
      uploaded_data$index <- 1
  else
    dtRendered(FALSE)
}) #updates the uploaded_data$index based on how many CSVs are uplaoded, works for any file naming convention

#renderDT
output$contents <- renderDT({ #displays the DT and allows to select rows/columns
  if((length(uploaded_data$csv_names)>0) & (uploaded_data$index<=length(uploaded_data$csv_names))){
    selected_file <- uploaded_data$data[[uploaded_data$index]]
    # targ <- switch(input$row_and_col_select,
    #                'rows' = 'row',
    #                'columns' = 'column')
    datatable(selected_file, 
             options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5))
  }
})

#deleting unwanted files with the select dropdown and removes them from the index
observeEvent(input$delete,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
})

observe({ #shinyJS code to show/hide an actionbutton to continue on to ordering page
  if(dtRendered()){ #dtRendered is a reactive value that's set to TRUE once table is displayed
    shinyjs::show("conditional")
  } else {
    shinyjs::hide("conditional")
  }
})

observeEvent(input$submit_delete, {
  val <- uploaded_data$index
  
  selected_rows <- as.integer(input$contents_rows_selected)
  selected_cols <- as.integer(input$contents_columns_selected)
  if (length(selected_rows) > 0) {
    uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
  }
  if (length(selected_cols) > 0) {
    uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
  }
}) #code to delete rows/columns

observeEvent(uploaded_data$data,  {
  js$enableUpload()
})

observeEvent(input$uploadContinue,{
  
  if(is.na(uploaded_data$data) || is.null(uploaded_data$data)){
    return()
  }
  
  comb_df <- do.call(rbind, uploaded_data$data)
  colnames(comb_df) <- c('Date_Time', 'station', 'Low_Range', 'Full_Range', 'High_Range', 'Temp_C') #naming columns
  comb_df <- comb_df %>% #saves following code as loaded
    mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
    mutate(Date_Time = mdy_hms(Date_Time, tz='GMT')) %>%#changes date_time to a mdy_hms format in gmt time zone
     mutate(Low_Range_Flag = "good", Full_Range_Flag = "good",
            High_Range_Flag = "good", Temp_C_Flag = "good", id = row.names(.))
  
  goop$combined_df <- comb_df

  melted_comb_df <- melt(comb_df,
                         id.vars = c("Date_Time", "station"),
                         measure.vars = c("Low_Range",
                                          "Full_Range",
                                          "High_Range",
                                          "Temp_C")) |>
    rename(Variable = variable,
           Station = station,
           Value = value) %>% mutate(Flag = "NA", id = row.names(.))

  goop$melted_combined_df <- melted_comb_df
  updateTabsetPanel(session, inputId = "navbar", selected = "trimpanel")
}) #rbind all the uploaded data frames

observe({
  onclick("instructions", paste0("my instructions"))
})
            