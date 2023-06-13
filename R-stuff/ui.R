library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  includeHTML("index.html"),
  tabsetPanel(
    tabPanel('Home', source("home.R")),
    tabPanel('Visualize', source("visualize.R")),
    tabPanel("Upload", source("upload.R"))
  ),
  tags$head(tags$script(src="script.js"))
)
