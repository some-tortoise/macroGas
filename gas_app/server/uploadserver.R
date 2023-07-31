# The app will use these keywords to detect and guess variable names
keywords <- c("NA","DO", "Date", "Low Range", "Full Range", "High Range", "Temp", "Abs") 

# Detect and guess variable names in a given data frame based on a predefined list of keywords
getGuesses <- function(df) {
  
  goop$guessList <- c()
  for(i in 1:length(colnames(df))){
    goop$guessList[i] <- NA
  }
  
  goop$colList <- colnames(df)
  
  
  for (i in 1:length(colnames(df))) {
    colName <- colnames(df)[i]
    for (keyword in keywords) {
      if (str_detect(colName, keyword)) {
        goop$guessList[i] <- keyword
      }
    }
  }
  
} 

# Generates a list of guessUI modules based on the columns in an uploaded file, 
# then applies  guessServer to handle the guessing process for each column.
observeEvent(goop$fileEntered, {
  getGuesses(goop$curr_df)
  output$guesses <- renderUI({
    LL <- vector("list",length(goop$colList))   
    ids <- c(1:length(goop$colList))
    for(i in 1:length(goop$colList)){
      LL[[i]] <- list(
        guessUI(id = ids[i], 
                colName = goop$colList[i], 
                guess = goop$guessList[i], 
                guessList = keywords
                )
        )
    }
    return(LL)
  })
  
  ids <- c(1:length(goop$colList))
  lapply(ids, function(i) {
    goop$guessList[i] <- guessServer(id = i, goop = goop, guessIndex = i)
  })
})  

# Sets up and processes information related to the uploaded data frame and its file name
add_df <- function(df, fileName) {
  
  goop$fileEntered <- 0
  goop$fileEntered <- 1
  siteGuess <- str_split(fileName, '_')[[1]][2]
  stationGuess <- str_split(fileName, '_')[[1]][3] 
  #Guesses station and site name based on assumption that the fileName has an underscore-separated format, and the second and third elements are used for site and station names.
  if(is.na(siteGuess)){
    siteGuess <- ''
  }
  if(is.na(stationGuess)){
    stationGuess <- ''
  }
  goop$siteName <- siteGuess
  goop$stationName <- stationGuess
  
  
  getGuesses(df)
  goop$curr_df <- df
} 

# When one or more CSV files are uploaded using the df_upload input, it reads the uploaded CSV files,
# processes each file using add_df function, and stores relevant information  
observeEvent(input$df_upload, {
  tryCatch({
    for(i in 1:length(input$df_upload[,1])){
      filePath <- input$df_upload[[i, 'datapath']]
      df <- read.csv(filePath, skip = ifelse(input$skipRow, 1, 0))
      fileName <- input$df_upload[[i, 'name']]
      add_df(df, fileName)
      }
    }, error = function (err){
      print(err)
      showModal(modalDialog(
        title = "Error",
        p("Could not upload file. Please try selecting the \'Skip First Row\' option."),
        easyClose = TRUE,
        footer = tagList(
          modalButton("Back")
        )
      ))
      return()
    })
}) 

# Reactives to store 
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

remove_shiny_inputs <- function(id, .input) {
  invisible(
    lapply(grep(id, names(.input), value = TRUE), function(i) {
      .subset2(.input, "impl")$.values$remove(i)
    })
  )
}

observeEvent(input$uploadBtn, {
  
  # Error Checking
  if(input$stationName == '' || input$siteName == ''){
    showModal(modalDialog(
      title = "Error",
      p("Please enter a station and site name"),
      easyClose = TRUE,
      footer = tagList(
        modalButton("Back")
      )
    ))
    return(FALSE)
  }
  
  includesDateTime <- FALSE
  for(i in 1:length(goop$guessList)){
    print(goop$guessList[i])
    if(!is.na(goop$guessList[i]) & goop$guessList[i] == 'Date'){
      includesDateTime <- TRUE
    }
  }
  if(includesDateTime == FALSE){
    showModal(modalDialog(
      title = "Error",
      p("There must be a date time column in your dataset"),
      easyClose = TRUE,
      footer = tagList(
        modalButton("Back")
      )
    ))
    return(FALSE)
  }
  
  for(i in 1:length(goop$guessList)){
    if(!is.na(goop$guessList[i]) & goop$guessList[i] == 'NA'){
      goop$guessList[i] <- NA
    }
  }
  df <- goop$curr_df
  colnames(df) <- goop$guessList
  df <- df[, !is.na(names(df))]
  
  
  names(df)[names(df) == 'Date'] <- 'Date_Time'
  names(df)[names(df) == 'Temp'] <- 'Temp_C'
  names(df)[names(df) == 'DO'] <- 'DO_conc'
  names(df)[names(df) == 'Abs'] <- 'Abs_Pres'
  names(df)[names(df) == 'Low Range'] <- 'Low_Range'
  names(df)[names(df) == 'High Range'] <- 'High_Range'
  names(df)[names(df) == 'Full Range'] <- 'Full_Range'
  
  df$Temp_C <- as.numeric(df$Temp_C)
  # Reshape df from wide to long format 
  df <- gather(df, key = "Variable", value = "Value", -1)
  
  # fix format of the date_time column
  df <- df %>% mutate(Date_Time = parse_date_time(Date_Time, "%m/%d/%y %I:%M:%S %p"))
  
  # remove rows containing NA
  df <- na.omit(df)
  
  # add Site, Station, and Flag columns to df
  df['Site'] <- goop$siteName
  df['Station'] <- goop$stationName
  df['Flag'] <- 'NA'
  
  # Combine df with existing data into goop$combined_df
  if(is.null(goop$combined_df)){ 
    goop$combined_df <- df
  }else{
    goop$combined_df <- rbind(goop$combined_df[1:ncol(goop$combined_df)-1], df)
  }
  
  # Add an id column to goop$combined_df
  goop$combined_df$id <- 1:nrow(goop$combined_df)
  
  # Store in a local variable combined_df
  combined_df <- goop$combined_df

  removeUI(selector = "#guess-el")
  for(i in 1:length(goop$colList)){
    remove_shiny_inputs(i, input)
  }
  goop$curr_df <- NULL
  goop$siteName <- ''
  goop$stationName <- ''
  
  output$guesses <- renderUI({})
}) 

