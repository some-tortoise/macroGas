library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- navbarPage(
  includeHTML("index.html"),
tabPanel(('Home'), source("home.R")),#HOME
tabPanel('Visualize', source("visualize.R")), #VISUALIZE
tabPanel("Upload", source("upload.R")), #UPLOAD
tags$head(tags$script(src="script.js")))
