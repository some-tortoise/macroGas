keywords <- c("NA","DO", "Date", "Low Range", "High Range", "Temp", "Abs") #the app will use these keywords to detect and guess variable names

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
  
} #detect and guess variable names in a given data frame based on a predefined list of keywords

observeEvent(goop$fileEntered, {
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
    guessServer(id = i, goop = goop, guessIndex = i)
  })
}) #generates a list of guessUI modules based on the columns in an uploaded file, then applies  guessServer to handle the guessing process for each column. 

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
} #sets up and processes information related to the uploaded data frame and its file name

observeEvent(input$df_upload, {
  tryCatch({
    for(i in 1:length(input$df_upload[,1])){
      filePath <- input$df_upload[[i, 'datapath']]
      df <- read.csv(filePath, skip = 1)
      fileName <- input$df_upload[[i, 'name']]
      add_df(df, fileName)
      }
    })
}) #when one or more CSV files are uploaded using the df_upload input, it reads the uploaded CSV files,
#processes each file using add_df function, and stores relevant information  

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
  
  for(i in 1:length(goop$guessList)){
    if(goop$guessList[i] == 'NA'){
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
  
  df <- gather(df, key = "Variable", value = "Value", -1)
  
  df <- df %>% mutate(Date_Time = parse_date_time(Date_Time, "%m/%d/%y %I:%M:%S %p"))
  
  df <- na.omit(df)
  
  df['Site'] <- goop$siteName
  df['Station'] <- goop$stationName
  df['Flag'] <- 'NA'
  
  if(is.null(goop$combined_df)){
    goop$combined_df <- df
  }else{
    goop$combined_df <- rbind(goop$combined_df[1:ncol(goop$combined_df)-1], df)
  }
  
  goop$combined_df$id <- 1:nrow(goop$combined_df)
  
  
  goop$curr_df <- NULL
  goop$siteName <- ''
  goop$stationName <- ''
  output$guesses <- renderUI({})
}) # processes the uploaded data frame, updates variable names, manipulates the data frame structure, 
#and combines the data with previously uploaded data