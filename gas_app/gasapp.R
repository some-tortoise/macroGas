#
# PACKAGES 
#

require(shiny) # for webpage creation
require(shinyjs)
require(shinyTime) 
require(shinyFiles)
require(shinyBS)
require(shinythemes)
require(reactlog)
require(htmlwidgets)

require(tidyverse)
require(DT) # for datatables
require(data.table)
require(lubridate)

require(plotly) # for interactive graphs
require(ggplot2)

require(googledrive)
require(sortable)
require(readr)
require(reshape2)
require(janitor)
require(remotes)
require(streamMetabolizer)
require(httr)
require(jsonlite)
require(gridExtra)

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

