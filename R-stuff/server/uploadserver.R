templateCSV <- data.frame(
    "Date_Time" = c("05/25/23 12:00:00 PM", "05/25/23 12:00:05 PM", "05/25/23 12:00:10 PM"),
    "Station" = c(1, 2, 3),
    "Low Range μS/cm" = c(1, 2, 3),
    "Full Range μS/cm" = c(1, 2, 3),
    "High Range μS/cm" = c(1, 2, 3),
    stringsAsFactors = FALSE)
  
  dtRendered <- reactiveVal(FALSE)

  uploaded_data <- reactiveValues(csv_names = NULL, 
                                  data = NULL,
                                  index = 1,
                                  station_names = NULL,
                                  combined_df = NULL)
  
observeEvent(input$uploadinstructions, { 
    showModal(modalDialog(
      title = "Instructions",
      "Download the data template using the 'Download File' button to see the required format. 
      Select your CSV file by clicking 'Choose CSV File' and then 'Open' to upload it.
      The uploaded file will be displayed in the table below.
      To delete a file, click the 'Delete' button next to it.
      For futher editing here, click the 'Advanced Editing' botton.
      Click the ? icon for help anytime!", 
      easyClose = TRUE))
  }) #instructions button

output$downloadFile <- downloadHandler( #data template download button
    filename = "slugtemplate.csv",
    content = function(file) {
      write.csv(templateCSV, file, row.names = FALSE)
    })

observeEvent(input$csvs, {
  uploaded_data <- reactiveValues(csv_names = NULL, 
                                  data = NULL,
                                  index = 1,
                                  station_names = NULL,
                                  combined_df = NULL)
})

output$downloadFile <- downloadHandler( #data template download button
  filename = "slugtemplate.csv",
  content = function(file) {
    write.csv(templateCSV, file, row.names = FALSE)
  })

observeEvent(input$upload, {
  req(input$upload)
  df <- read.csv(input$upload$datapath)
  
  if (!identical(colnames(df), colnames(templateCSV))) {
    showModal(modalDialog(
      title = "Error",
      "Uploaded CSV must have identical columns to the given template. If you do not have certain data, please leave that respective column blank."
    ))
  } else if (length(colnames(df)) > length(colnames(templateCSV))) {
    showModal(modalDialog(
      title = "Error",
      "Uploaded CSV has more columns than given template."
    ))
  } else {
    # Store uploaded data in the reactive uploaded_data value
    uploaded_data$data <- df
    dtRendered(TRUE)
    output$contents <- renderDT({
      datatable(df)
    })
  }
  
  # naming conventions for stored data
  seq_csv <- seq_along(input$upload$name)
  prev_num_files <- length(uploaded_data$data)
  uploaded_data$csv_names <- c(uploaded_data$csv_names, input$upload$name)
  
  output$selectfiles <- renderUI({  
    if(is.null(input$upload)) {return()}
    selectInput("select", "Select Files", choices = uploaded_data$csv_names)
  })
  
}) # all the code to upload, validate, display, and select user-uploaded

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
}) #updates the uploaded_data$index based on how many CSVs are uplaoded

observeEvent(input$delete,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
}) #deleting unwanted files

observe({ #shinyJS code to show/hide an actionbutton to continue on to ordering page
  if(dtRendered()){ #dtRendered is a reactive value that's set to TRUE once table is displayed
    shinyjs::show("conditional")
  } else {
    shinyjs::hide("conditional")
  }
})



##old stuff to save for later##

# output$table1 <- renderDT({
#   if(length(uploaded_data$data)>0){
#     targ <- switch(input$row_and_col_select,
#                    'rows' = 'row',
#                    'columns' = 'column')
# 
#     datatable(uploaded_data$data[[uploaded_data$index]], selection = list(target = targ),
#               options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5))
#   }
# })
# 
# observeEvent(input$submit_delete, {
#   val <- uploaded_data$index
#   
#   selected_rows <- as.integer(input$table1_rows_selected)
#   selected_cols <- as.integer(input$table1_columns_selected)
#   if (length(selected_rows) > 0) {
#     uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
#   }
#   if (length(selected_cols) > 0) {
#     uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
#   }
# })
# 
# observeEvent(input$viz_btn, {
#   # combine all elements of uploaded$data
#   # add column with station names
#   uploaded_data$combined_df <- '\'visualized\''
#   print(uploaded_data$combined_df)
# })

