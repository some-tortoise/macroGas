library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

# LOAD IN METHOD CHOICE
homeserver <- function(input, output, session){
  output$downloadFile <- downloadHandler(
    filename = "saltslug_exampledata.csv",
    content = function(file) {
      file_path <- "saltslug_exampledata.csv"  
      file.copy(file_path, file)})
  
  
  observeEvent(input$manual_choice, {
    show("manual_container")
    show("viz_container_div")
  })
  
  #hide("manual_container")
  #hide("viz_container_div")
  
  observeEvent(input$gdrive_choice, {
    #alert('This option is currently unavailable.')
    show("viz_container_div")
  })
}
