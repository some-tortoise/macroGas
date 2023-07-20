getGuesses <- function(df) {
  keywords <- c("DO", "Date", "Range", "Temp", "Abs")
  
  goop$guessList <- c()
  for(i in 1:length(colnames(file_data))){
    goop$guessList[i] <- NA
  }
  
  goop$colList <- colnames(file_data)
  
  
  for (i in 1:length(colnames(file_data))) {
    colName <- colnames(file_data)[i]
    for (keyword in keywords) {
      if (str_detect(colName, keyword)) {
        goop$guessList[i] <- keyword
      }
    }
  }
  
}

observeEvent(goop$fileEntered, {
  output$guesses <- renderUI({
    LL <- vector("list",length(goop$colList))   
    ids <- c(1:length(goop$colList))
    for(i in 1:length(goop$colList)){
      LL[[i]] <- list(
        guessUI(id = ids[i], 
                colName = goop$colList[i], 
                guess = goop$guessList[i], 
                guessList = unique(goop$guessList)
                )
        )
    }
    return(LL)
  })
  
  ids <- c(1:length(goop$colList))
  lapply(ids, function(i) {
    guessServer(id = i)
  })
})

add_df <- function(df, fileName) {
  
  goop$fileEntered <- 0
  goop$fileEntered <- 1
  
  siteGuess <- str_split(fileName, '_')[[1]][2]
  stationGuess <- str_split(fileName, '_')[[1]][3]
  goop$siteName <- siteGuess
  goop$stationName <- stationGuess
  
  
  getGuesses(df)
  goop$curr_df <- df
}

observeEvent(input$df_upload, {
  tryCatch({
    for(i in 1:length(input$df_upload[,1])){
      filePath <- input$df_upload[[i, 'datapath']]
      df <- read.csv(filePath, skip = 1)
      fileName <- input$df_upload[[i, 'name']]
      add_df(df, fileName)
      }
    })
})

goop$siteName <- 'Placeholder'
goop$stationName <- 'Placeholder'

output$siteNameUI <- renderUI({
  textInput('siteName','', value = goop$siteName)
})

output$stationNameUI <- renderUI({
  textInput('stationName','', value = goop$stationName)
})

observeEvent(input$siteName,{
  goop$siteName <- input$siteName
})

observeEvent(input$stationName,{
  goop$stationName <- input$stationName
})

output$contents <- renderDT({
  datatable(goop$curr_df)
})

observeEvent(input$uploadBtn, {
  
  df <- bind_rows(c(goop$combined_df, goop$curr_df))  # Combine the filtered data frames into a single data frame
  stacked_data <- gather(df, key = "Variable", value = "Value", -1)
  stacked_data <- slice(stacked_data, -(1))
  stacked_data$Variable <- ifelse(grepl("Temp C", stacked_data$Variable), "Temp_C", stacked_data$Variable)
  stacked_data$Variable <- ifelse(grepl("Low Range", stacked_data$Variable), "Low_Range", stacked_data$Variable)
  stacked_data$Variable <- ifelse(grepl("High Range", stacked_data$Variable), "High_Range", stacked_data$Variable)
  stacked_data$Variable <- ifelse(grepl("Full Range", stacked_data$Variable), "Full_Range", stacked_data$Variable)
  stacked_data$Variable <- ifelse(grepl("Abs", stacked_data$Variable), "Abs_Pres", stacked_data$Variable)
  stacked_data$Variable <- ifelse(grepl("DO", stacked_data$Variable), "DO_Conc", stacked_data$Variable)
  
  goop$combined_df <- stacked_data
  
  print('Dataset Added!')
  goop$curr_df <- NULL
  goop$siteName <- ''
  goop$stationName <- ''
  output$guesses <- renderUI({})
})



# uploaded_data <- reactiveValues(csv_names = NULL, 
#                                 data = NULL,
#                                 index = 1,
#                                 station_names = NULL,
#                                 combined_df = NULL)
# 
# observeEvent(input$upload, {
#   req(input$upload)
#   tryCatch(
#     {
#       for(i in 1:length(input$upload[,1])){
#         df <- read.csv(input$upload[[i, 'datapath']])
#         fileName <- input$upload[[i, 'name']]
#         print(fileName)
#       }
#     })
# })
# 
# observe({
#   if(length(uploaded_data$csv_names) > 0)
#     if(length(uploaded_data$csv_names) > 1){
#       for(i in 1:length(uploaded_data$csv_names)){
#         if(input$select == uploaded_data$csv_names[i]){
#           uploaded_data$index <- i
#         }
#       } 
#     }
#   else
#     uploaded_data$index <- 1
#   else
#     dtRendered(FALSE)
# }) #updates the uploaded_data$index based on how many CSVs are uplaoded, works for any file naming convention
# 
# output$contents <- renderDT({ #displays the DT and allows to select rows/columns
#   if((length(uploaded_data$csv_names)>0) & (uploaded_data$index<=length(uploaded_data$csv_names))){
#     selected_file <- uploaded_data$data[[uploaded_data$index]]
#     # targ <- switch(input$row_and_col_select,
#     #                'rows' = 'row',
#     #                'columns' = 'column')
#     datatable(selected_file, 
#               options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5))
#   }
# })
# 
# #deleting unwanted files with the select dropdown and removes them from the index
# observeEvent(input$delete,{
#   index = uploaded_data$index
#   uploaded_data$data <- uploaded_data$data[-index]
#   uploaded_data$csv_names <- uploaded_data$csv_names[-index]
#   updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
# })
# 
# observe({ #shinyJS code to show/hide an actionbutton to continue on to ordering page
#   if(dtRendered()){ #dtRendered is a reactive value that's set to TRUE once table is displayed
#     shinyjs::show("conditional")
#   } else {
#     shinyjs::hide("conditional")
#   }
# })
# 
# observeEvent(input$submit_delete, {
#   val <- uploaded_data$index
#   
#   selected_rows <- as.integer(input$contents_rows_selected)
#   selected_cols <- as.integer(input$contents_columns_selected)
#   if (length(selected_rows) > 0) {
#     uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
#   }
#   if (length(selected_cols) > 0) {
#     uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
#   }
# }) #code to delete rows/columns
# 
# observeEvent(uploaded_data$data,  {
#   js$enableUpload()
# })
# 
# observeEvent(input$uploadContinue,{
#   
#   if(is.na(uploaded_data$data) || is.null(uploaded_data$data)){
#     return()
#   }
#   
#   
#   comb_df <- do.call(rbind, uploaded_data$data)
#   colnames(comb_df) <- c('Date_Time', 'station', "site", 'Low_Range', 'Full_Range', 'High_Range', "Do_Conc", 'Temp_C') #naming columns
#   comb_df <- comb_df %>% #saves following code
#     mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
#     mutate(Date_Time = mdy_hms(Date_Time, tz='EST')) %>%#changes date_time to a mdy_hms format in EST time zone
#   
#   goop$combined_df <- comb_df
#   
#   melted_comb_df <- melt(comb_df,
#                          id.vars = c("Date_Time", "station", "site"),
#                          measure.vars = c("Low_Range",
#                                           "Full_Range",
#                                           "High_Range",
#                                           "DO_Conc",
#                                           "Temp_C")) |>
#     rename(Variable = variable,
#            Station = station,
#            Site = site,
#            Value = value) %>% mutate(Flag = "NA", id = row.names(.))
# })
# observe({
#   onclick("instructions", paste0("my instructions"))
# })
# 
