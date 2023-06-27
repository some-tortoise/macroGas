templateCSV <- data.frame(
  "Date_Time" = c("05/25/23 12:00:00 PM", "05/25/23 12:00:05 PM", "05/25/23 12:00:10 PM"),
  "Station" = c(1, 1, 1),
  "DO_conc_mg_L" = c(1, 2, 3),
  "Temp_C" = c(1, 2, 3),
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
  filename = "DOtemplate.csv",
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
      uploaded_data$data[[length(uploaded_data$data) + 1]] <- csv_file #stores a correctly formatted data in uploaded_data$data as a separate element (i think ?)
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

#renderDT
output$contents <- renderDT({ #displays the DT and allows to select rows/columns
  if((length(uploaded_data$csv_names)>0) & (uploaded_data$index<=length(uploaded_data$csv_names))){
    selected_file <- uploaded_data$data[[uploaded_data$index]]
    targ <- switch(input$row_and_col_select,
                   'rows' = 'row',
                   'columns' = 'column')
    datatable(selected_file, selection = list(target = targ),
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

observeEvent(input$continue_button,{
  comb_df <- do.call(rbind, uploaded_data$data)
  colnames(comb_df) <- c('Date_Time', 'station', 'DO_conc_mg_L','Temp_C') #naming columns
  comb_df <- comb_df %>% #saves following code as loaded
    mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
    mutate(Date_Time = mdy_hms(Date_Time, tz='GMT')) #changes date_time to a mdy_hms format in gmt time zone
  View(comb_df)
  goop$combined_df <- comb_df
}) #rbind all the uploaded data frames



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
# }) #able to switch between editing rows and columns
# 

# 
# observeEvent(input$viz_btn, {
#   # combine all elements of uploaded$data
#   # add column with station names
#   uploaded_data$combined_df <- '\'visualized\''
#   print(uploaded_data$combined_df)
# })

