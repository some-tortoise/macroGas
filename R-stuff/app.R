library(shiny) # for webpage creation
library(reactlog)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data
# tell shiny to log all reactivity
reactlog_enable()


ui <- fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    source('ui/navbar.R')[1],
    div(class = 'tabbable',
        source("ui/home.R")[1],
        source("ui/upload.R")[1],
        source("ui/flag.R")[1],
        source("ui/calculate.R")[1],
        source("ui/visualize.R")[1]
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


source("server/mainserver.R")
server <-  function(input, output, session) {
    # Call the server functions from the included files
    mainserver(input, output, session)}


shinyApp(ui = ui, server = server)
