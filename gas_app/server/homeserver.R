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
observeEvent(input$upload, {
  req(input$upload)
  tryCatch({df = read.csv(input$upload$datapath)}, error = function(e) df=NULL) #using the df value just to check formatting, usin a new variable to save to uploaded_data later
  check_format(df, input$upload$name)
})

#deleting unwanted files with the select dropdown and removes them from the index
observeEvent(input$delete,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
})
observeEvent(input$continue_button,{
  comb_df <- do.call(rbind, uploaded_data$data)
  colnames(comb_df) <- c('Date_Time', 'station', 'Low_Range', 'Full_Range', 'High_Range', 'Temp_C') #naming columns
  comb_df <- comb_df %>% #saves following code as loaded
    mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
    mutate(Date_Time = mdy_hms(Date_Time, tz='GMT')) #changes date_time to a mdy_hms format in gmt time zone
  #View(comb_df)
  goop$combined_df <- comb_df
  updateTabsetPanel(session, inputId = "navbar", selected = "trimpanel")
}) #rbind all the uploaded data frames
