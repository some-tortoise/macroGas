#
# PACKAGES 
#

library(shiny) # for webpage creation
library(tidyverse)
library(data.table)
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
library(lubridate)
library(reshape2)
library(janitor)
library(remotes)
library(streamMetabolizer)
library(ggplot2)

# hard coding the location of the processed folder in the macrogas google drive
PROCESSED_FOLDER <- "https://drive.google.com/drive/u/0/folders/1Ot7VH5dBjkAWFmtOLcA5p5_nyR3lN5ga"

Sys.setenv(GOOGLE_APPLICATION_CREDENTIALS = "keyFile.json")
drive_auth()

#
# 
#

ui <- fluidPage(
  class = 'body-container',
  theme = shinytheme("flatly"),
  tags$head(
    HTML(
      '<link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">'
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  navbarPage('Gas App', id = "navbar",
              theme = shinytheme("flatly"),
             useShinyjs(),
             tabPanel('Home',
                      source("ui/homeUI.R")[1]), 
             tabPanel('Upload',
                      source("ui/uploadUI.R")[1]),
             tabPanel('QA/QC',
                      source("ui/qaqcUI.R")[1]),
             tabPanel("View",
                     source("ui/viewUI.R")[1]),
             tabPanel("DO Data and Metrics", value = "DO",
                      source("ui/DOUI.R")[1])
              )
  )

server <- function(input, output, session) {
  goop <- reactiveValues() 
  goop$combined_df <- NULL
  
  # Call the server functions from the included files
  source("server/homeserver.R", local = TRUE)
  source("server/uploadserver.R", local = TRUE)
  source("server/qaqcserver.R", local = TRUE)
  source("server/viewserver.R", local = TRUE)
  source("server/DOserver.R", local = TRUE)
}

shinyApp(ui, server)

