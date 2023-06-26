library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

# LOAD IN METHOD CHOICE

  output$downloadFile <- downloadHandler(
    filename = "saltslug_exampledata.csv",
    content = function(file) {
      file_path <- "saltslug_exampledata.csv"  
      file.copy(file_path, file)})
  
  
  observeEvent(input$manual_choice, {
  })
  
  observeEvent(input$gdrive_choice, {
    goop$val1 <- paste0('Hello',goop$val1)
  })

