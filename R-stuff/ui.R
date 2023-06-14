library(shiny) # for webpage creation
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  #includeHTML("index.html"),
  tags$head(tags$script(src="script.js")),
  source('navbar.R'),
  tabsetPanel(
    tabPanel('Home', source("home.R")),
    tabPanel('Visualize', source("visualize.R")),
    tabPanel("Upload", source("upload.R"))
  )
)
