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


ui <- fluidPage(
  navbarPage('Gas App',
             tabPanel('Home',
                      source("ui/homeUI.R")[1]),
             tabPanel('Upload',
                      source("ui/uploadUI.R")[1]),
             tabPanel('Flag',
                      source("ui/flagUI.R")[1]),
             tabPanel('Calculate',
                      source("ui/calculateUI.R")[1])
  )
    
)

server <- function(input, output, session) {
  combined_df <- NULL
  goop <- reactiveValues()
  goop$combined_df <- combined_df
  
  # Call the server functions from the included files
  source("server/uploadserver.R", local = TRUE)
  source("server/flagserver.R", local = TRUE)
  source("server/calculateserver.R", local = TRUE)
}


shinyApp(ui, server)
