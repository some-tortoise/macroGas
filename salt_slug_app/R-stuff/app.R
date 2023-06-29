library(shiny) # for webpage creation
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
library(tidyverse)
library(dplyr)
library(shinythemes)

reactlog_enable()

ui <- fluidPage(
  theme = shinytheme("flatly"),
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  navbarPage('SLUGS', id = "navbar",
                 tabPanel('Home',
                          source("ui/home.R")[1]),
                 tabPanel('Upload',
                          source("ui/upload.R")[1]),
                 tabPanel(title = 'QA/QC',
                          value = "flagpanel",
                          source("ui/flag.R")[1]),
                 tabPanel('Calculate',
                          source("ui/calculate.R")[1])
             ),
  includeScript(path = "www/script.js")
  )

server <-  function(input, output, session) {
  
    goop <- reactiveValues()
    goop$combined_df <- combined_df
    
    # Call the server functions from the included files
    source("server/homeserver.R", local = TRUE)
    source("server/uploadserver.R", local = TRUE)
    source("server/flagserver.R", local = TRUE)
    source("server/calculateserver.R", local = TRUE)
}

shinyApp(ui = ui, server = server)
