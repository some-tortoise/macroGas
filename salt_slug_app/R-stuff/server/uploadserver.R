#
# DATA TEMPLATE AND SET UP
#

# The template data for users to download
templateCSV <- data.frame(
  "Date_Time" = c("5/25/23 13:33:15", "5/25/23 13:33:20", "5/25/23 13:33:25", "5/25/23 13:33:30", "5/25/23 13:33:35", "5/25/23 13:33:40", "5/25/23 13:33:45", "5/25/23 13:33:50", "5/25/23 13:33:55", "5/25/23 13:34:00", "5/25/23 13:34:05", "5/25/23 13:34:10", "5/25/23 13:34:15", "5/25/23 13:34:20", "5/25/23 13:34:25", "5/25/23 13:34:30", "5/25/23 13:34:35", "5/25/23 13:34:40", "5/25/23 13:34:45", "5/25/23 13:34:50", "5/25/23 13:34:55", "5/25/23 13:35:00", "5/25/23 13:35:05", "5/25/23 13:35:10", "5/25/23 13:35:15", "5/25/23 13:35:20", "5/25/23 13:35:25", "5/25/23 13:35:30", "5/25/23 13:35:35", "5/25/23 13:35:40", "5/25/23 13:35:45", "5/25/23 13:35:50", "5/25/23 13:35:55", "5/25/23 13:36:00", "5/25/23 13:36:05", "5/25/23 13:36:10", "5/25/23 13:36:15", "5/25/23 13:36:20", "5/25/23 13:36:25", "5/25/23 13:36:30", "5/25/23 13:36:35", "5/25/23 13:36:40", "5/25/23 13:36:45", "5/25/23 13:36:50", "5/25/23 13:36:55", "5/25/23 13:37:00", "5/25/23 13:37:05", "5/25/23 13:37:10", "5/25/23 13:37:15", "5/25/23 13:37:20", "5/25/23 13:37:25", "5/25/23 13:37:30", "5/25/23 13:37:35", "5/25/23 13:37:40", "5/25/23 13:37:45"),
  "Station" = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
  "Low_Range" = c(125.8, 126.1, 126.4, 126.6, 127.0, 127.2, 127.5, 127.5, 127.7, 127.8, 128.9, 134.3, 153.9, 167.6, 206.2, 270.2, 331.9, 383.4, 417.1, 434.6, 437.6, 428.3, 394.3, 369.6, 335.8, 292.1, 271.6, 235.6, 221.0, 196.0, 185.1, 164.7, 156.8, 143.3, 139.7, 137.6, 134.5, 133.1, 130.9, 129.7, 128.9, 128.6, 128.1, 127.7, 127.5, 127.5, 127.1, 127.1, 126.8, 126.7, 126.6, 126.4, 126.4, 126.4, 126.3),
  "Full_Range" = c(128.8, 129.6, 129.6, 130.3, 130.3, 130.7, 130.7, 130.7, 131.1, 131.1, 132.7, 138.1, 159.8, 174.9, 217.3, 287.3, 355.7, 414.2, 452.2, 472.1, 475.7, 464.5, 426.0, 397.9, 360.4, 312.0, 289.6, 249.7, 233.3, 206.0, 194.0, 171.8, 163.3, 148.5, 144.3, 142.0, 138.9, 136.9, 134.6, 133.1, 132.3, 131.9, 131.5, 130.7, 130.7, 130.7, 130.3, 130.7, 130.3, 130.0, 130.0, 129.6, 129.6, 129.6, 129.6),
  "Temp_C" = c(18.29, 18.27, 18.27, 18.27, 18.27, 18.27, 18.27, 18.29, 18.27, 18.29, 18.29, 18.27, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.29, 18.30, 18.30, 18.29, 18.29, 18.29, 18.30, 18.30, 18.30, 18.30, 18.29, 18.29, 18.30, 18.30, 18.29, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.30, 18.29, 18.30, 18.30, 18.30),
  stringsAsFactors = FALSE)

dtRendered <- reactiveVal(FALSE) #set dtRendered to False, once data is uploaded correctly will set to TRUE for later use

# Reactive value to store future csv_names, data, station_names, and combined_df. Index initialized at 1 as a counter.
uploaded_data <- reactiveValues(csv_names = NULL, 
                                data = NULL,
                                index = 1,
                                station_names = NULL,
                                combined_df = NULL)

#
# UPLOADING/DELETING DATA
#

# Download handler for downloading the template
output$downloadFile <- downloadHandler( 
    filename = "slugtemplate.csv",
    content = function(file) {
      write.csv(templateCSV, file, row.names = FALSE)
      })


# Function for checking the format of uploaded files and updating list of uploaded CSVs
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
    dtRendered(TRUE) # Set dtRendered to true once uploaded successfully
    if(file_name %in% uploaded_data$csv_names){ # Won't store the new data if file_name already exists (user has re-uploaded the same thing)
      return(TRUE)
    }
    else{
      uploaded_data$data[[length(uploaded_data$data) + 1]] <- csv_file # Stores a correctly formatted data in uploaded_data$data as a separate element
      uploaded_data$csv_names <- c(uploaded_data$csv_names, file_name) # Adds file_name to list of uploaded csvs
      updateSelectInput(session, 'select', choices = uploaded_data$csv_names, selected = file_name) # Updates the select csv to include new csv
    }
  }
}

### MANUAL UPLOAD CLEAN CSVs ###

# Manually upload data
observeEvent(input$upload, {
  req(input$upload)
  tryCatch(
    {
      for(i in 1:length(input$upload[,1])){ # For loop to store read in CSV data, file name, and check format of all uploaded files
        df <- read.csv(input$upload[[i, 'datapath']])
        fileName <- input$upload[[i, 'name']]
        check_format(df, fileName) # Call check_format on uploaded data
      }
      #df = read.csv(input$upload$datapath)
    },
    error = function(e) {
      df = NULL
      showModal(modalDialog(
        title = "Error",
        p("Could not read CSV file. Please check that your data does not have a header before uploading."),
        easyClose = FALSE,
        footer = tagList(
        modalButton("Back")
      )
      )
      )
    }
  )
})
      

### MANUAL UPLOAD HOBOS ###

# Function for cleaning HOBO files
clean_hobo <- function(csv_file){
  clean_csv_file <- csv_file %>%
    select(-1) %>%
    rename_at(vars(1:4), ~ c("Date_Time", "Low_Range", "Full_Range", "Temp_C")) %>%
    mutate(Station = input$stationupload) %>%
    select(Date_Time, Station, Low_Range, Full_Range, Temp_C)
  
    return(clean_csv_file)
  
}

# Modal HOBO box
observeEvent(input$hobobutton, {
  showModal(
    modalDialog(
      easyClose = TRUE,
      footer = NULL, 
      p(HTML("To correctly assign stations, you can only upload data from one station at a time. <b><i>Please input the correct station number before uploading.</i></b>")),
      numericInput("stationupload", "Station:", 1),
      fileInput("hoboupload", "Upload HOBO CSVs:",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
      )
    )
  )
})

observeEvent(input$hoboupload, {
  req(input$hoboupload)
  tryCatch(
    {
      for(i in 1:length(input$hoboupload[,1])){
        df <- read_csv(input$hoboupload[[i, 'datapath']], skip = 1, show_col_types = FALSE)
        file_name <- input$hoboupload[[i, 'name']]
        clean_csv_file <- clean_hobo(df)
        
        dtRendered(TRUE) # Set dtRendered to true once uploaded successfully
        
        if(file_name %in% uploaded_data$csv_names) { # Won't store the new data if file_name already exists (user has re-uploaded the same thing)
          return(TRUE)
        } else {
          uploaded_data$data[[length(uploaded_data$data) + 1]] <- clean_csv_file # Stores a correctly formatted data in uploaded_data$data as a separate element
          uploaded_data$csv_names <- c(uploaded_data$csv_names, file_name) # Adds file_name to list of uploaded csvs
          updateSelectInput(session, 'select', choices = uploaded_data$csv_names, selected = file_name) # Updates the select csv to include new csv
        }
      }
    }, error = function(e) {
      print(paste("Error occurred:", e))
    }
  )
})

# Updating uploaded_data$index based on how many CSVs are uploaded, works for any file naming convention
observe({
  if(length(uploaded_data$csv_names) > 0)
    if(length(uploaded_data$csv_names) > 1){ 
      for(i in 1:length(uploaded_data$csv_names)){ # for loop to update uploaded_data with index of each CSV
        if(input$select == uploaded_data$csv_names[i]){
          uploaded_data$index <- i
        }
      } 
    }
    else
      uploaded_data$index <- 1 # Set index to 1 if only one file
  else
    dtRendered(FALSE) # if length isn't > 0, set dtRendered to FALSE 
}) 

# Deleting files with the select dropdown and removing them from the index
observeEvent(input$delete,{
  index = uploaded_data$index
  uploaded_data$data <- uploaded_data$data[-index]
  uploaded_data$csv_names <- uploaded_data$csv_names[-index]
  updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
})


#
# DATATABLE 
#

# Display the datatable for the correct station
output$contents <- renderDT({ 
  if((length(uploaded_data$csv_names)>0) & (uploaded_data$index<=length(uploaded_data$csv_names))){
    selected_file <- uploaded_data$data[[uploaded_data$index]] # get selected_file from the data that matches the station index
    
    # Create a datatable to display the selected file
    datatable(selected_file, 
             options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 20))
  }
})

#
# CONTINUE BUTTON / BINDING DATA
# 

#shinyJS code to show/hide a conditional action button to continue on to ordering page using dtRendered T/F value
observe({ 
  if(dtRendered()){ #dtRendered is a reactive value that's set to TRUE once table is displayed
    shinyjs::show("conditional")
  } else {
    shinyjs::hide("conditional")
  }
})

# Triggers  'enableUpload()' JavaScript function when data changes using shinyjs
observeEvent(uploaded_data$data,  {
  js$enableUpload()
})

# Rbind all of the uploaded data frames
observeEvent(input$uploadContinue,{
  if(length(uploaded_data$data) <= 1){
    if(is.na(uploaded_data$data) || is.null(uploaded_data$data)){
      return()
    }
  }

  comb_df <- do.call(rbind, uploaded_data$data)
  colnames(comb_df) <- c('Date_Time', 'station', 'Low_Range', 'Full_Range', 'Temp_C') #naming columns
  comb_df <- comb_df %>% #saves following code
    mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
    mutate(Date_Time = mdy_hms(Date_Time, tz='EST')) %>% #changes date_time to a mdy_hms format in est time zone
    mutate(Low_Range_Flag = "good", Full_Range_Flag = "good", 
            Temp_C_Flag = "good", id = row.names(.))
  
  goop$combined_df <- comb_df
  
  updateTabsetPanel(session, inputId = "navbar", selected = "trimpanel")
}) 

