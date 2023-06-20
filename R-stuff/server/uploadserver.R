library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data
  
templateCSV <- data.frame(
  "Date_Time" = c("05/25/23 12:00:00 PM", "05/25/23 12:00:05 PM", "05/25/23 12:00:10 PM"),
  "Station" = c(1, 2, 3),
  "Low Range μS/cm" = c(1, 2, 3),
  "Full Range μS/cm" = c(1, 2, 3),
  "High Range μS/cm" = c(1, 2, 3),
  stringsAsFactors = FALSE
)
#uploadserver <- function(input, output, session){
  
  templateCSV <- data.frame(
    "Date_Time" = c("05/25/23 12:00:00 PM", "05/25/23 12:00:05 PM", "05/25/23 12:00:10 PM"),
    "Station" = c(1, 2, 3),
    "Low Range μS/cm" = c(1, 2, 3),
    "Full Range μS/cm" = c(1, 2, 3),
    "High Range μS/cm" = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
  
  uploaded_data <- reactiveValues(csv_names = NULL, 
                                  data = NULL,
                                  index = 1,
                                  station_names = NULL,
                                  combined_df = NULL)
  
observeEvent(input$uploadinstruction, { 
    showModal(modalDialog(
      title = "Instructions",
      "Download the data template using the 'Download File' button to see the required format. 
      Select your CSV file by clicking 'Choose CSV File' and then 'Open' to upload it.
      The uploaded file will be displayed in the table below.
      To delete a file, click the 'Delete' button next to it.
      For futher editing here, click the 'Advanced Editing' botton.
      Click the ? icon for help anytime!", 
      easyClose = TRUE
    ))
  }) #instructions button function"

  output$downloadFile <- downloadHandler(
    filename = "slugtemplate.csv",
    content = function(file) {
      write.csv(templateCSV, file, row.names = FALSE)
    }
  )
  
observeEvent(input$csvs, {
uploaded_data <- reactiveValues(csv_names = NULL, 
                                data = NULL,
                                index = 1,
                                station_names = NULL,
                                combined_df = NULL)
})

observeEvent(input$uploadinstruction, { 
  showModal(modalDialog(
    title = "File Upload Instructions",
    "Click the 'Download File' button to see the required format. 
      Select your CSV file by clicking 'Choose CSV File' and then 'Open' to upload it.
      The uploaded file will be displayed in the table below.
      To delete a file, click the 'Delete' button.
      For futher editing here, click the 'Advanced Editing' botton.
      Click the ? icon for help anytime!"
  ))        
  easyClose = TRUE
}) #instructions button function

output$downloadFile <- downloadHandler(
  filename = "slugtemplate.csv",
  content = function(file) {
    write.csv(templateCSV, file, row.names = FALSE)
  }
)

observeEvent(input$csvs, {
  in_file <- NULL
  success <- FALSE
  tryCatch({
    in_file <- read.csv(input$csvs$datapath,
                        header = TRUE,
                        sep = ",")
  }, error = function(e){
    in_file <- NULL
  })
  
  if(!is.null(in_file)){
    names <- colnames(in_file)
    if("Station" %in% names){
      if(identical(sort(names), sort(c("Date_Time", "Station", "Low_Range", "Full_Range", "High_Range", "Temp_C"))))
        success <- TRUE
    }
    else{
      if(identical(sort(names), sort(c("Date_Time", "Low_Range", "Full_Range", "High_Range", "Temp_C"))))
        success <- TRUE
    }
  }
  
  if(success){
    showModal(modalDialog(
      h3("Your file is uploaded successfully!"),
      footer = tagList(
        modalButton('OK')
      )
    ))
    seq_csv <- seq(length(input$csvs$name))
    prev_num_files <- length(uploaded_data$data)
    
    uploaded_data$csv_names[[prev_num_files + 1]] <- input$csvs$name
    uploaded_data$data[[prev_num_files + 1]] <- as.data.frame(in_file)
    updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
  }
  else{
    showModal(modalDialog(
      h3("Your file upload failed! Please check the format of your file!"),
      footer = tagList(
        modalButton('OK')
      )
    ))
  }
})

observe({
  if(length(uploaded_data$csv_names) > 1){
    for(i in 1:length(uploaded_data$csv_names)){
      if(input$select == uploaded_data$csv_names[i]){
        uploaded_data$index <- i
      }
    } 
  }
  else
    uploaded_data$index <- 1
})

observeEvent(input$Del,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
})

output$table1 <- renderDT({
  if(length(uploaded_data$data)>0){
    targ <- switch(input$row_and_col_select,
                   'rows' = 'row',
                   'columns' = 'column')
    
    datatable(uploaded_data$data[[uploaded_data$index]], selection = list(target = targ),
              options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5)) 
  }
})

observeEvent(input$submit_delete, {
  val <- uploaded_data$index
  
  selected_rows <- as.integer(input$table1_rows_selected)
  selected_cols <- as.integer(input$table1_columns_selected)
  if (length(selected_rows) > 0) {
    uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
  }
  if (length(selected_cols) > 0) {
    uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
  }
})

observeEvent(input$viz_btn, {
  # combine all elements of uploaded$data
  # add column with station names
  uploaded_data$combined_df <- '\'visualized\''
  print(uploaded_data$combined_df)
})
#}