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

#deleting unwanted files with the select dropdown and removes them from the index
observeEvent(input$delete,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
})