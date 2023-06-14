library(shiny) # for webpage creation
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  source('navbar.R')[1],
  div(class = 'tabbable',
      source("home.R")[1],
      source("upload.R")[1],
      source("flag.R")[1],
      source("calculate.R")[1],
      source("visualize.R")[1]
      ),
  
  # tabsetPanel(
  #   tabPanel('Home', source("home.R")[1]),
  #   tabPanel("Upload", source("upload.R")[1]),
  #   tabPanel('Flag', source("flag.R")[1]),
  #   tabPanel('Calculate', source("calculate.R")[1]),
  #   tabPanel('Visualize', source("visualize.R")[1])
  # ),
  includeScript(path = "www/script.js")
)
