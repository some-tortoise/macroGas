library(shiny) # for webpage creation
library(tidyverse)
library(reactlog)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime) 
library(sortable)
library(googledrive)
library(readr)
library(shinyBS)
library(shinythemes)

#combined_df <- get from google drive stuff
ui <- fluidPage(
  navbarPage('Gas App',
              theme = shinytheme("flatly"),
             useShinyjs(),
             tabPanel('Home',
                      source("ui/homeUI.R")[1]),
             tabPanel('QA/QC',
                      source("ui/qaqcUI.R")[1])
  )
    
)

server <- function(input, output, session) {
  goop <- reactiveValues()
  goop$combined_df <- combined_df
  
  # Call the server functions from the included files
  source("server/qaqcserver.R", local = TRUE)
}


shinyApp(ui, server)
