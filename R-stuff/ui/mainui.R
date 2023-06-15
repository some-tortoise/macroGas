library(shiny) # for webpage creation
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

mainUI <- function(){
  fluidPage(
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
  includeScript(path = "www/script.js")
)
}
