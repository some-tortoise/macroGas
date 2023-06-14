library(shiny) # for webpage creation
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  #includeHTML("index.html"),
  tags$head(tags$script(src="script.js")),
  source('navbar.R'),
  tabsetPanel(
    tabPanel('Home', source("home.R")),
    tabPanel("Upload", source("upload.R")),
    tabPanel('Flag', source("flag.R")),
    tabPanel('Calculate', source("math.R")),
    tabPanel('Visualize', source("visualize.R"))
    
  ),
  tags$head(tags$script(src="script.js"))
)
