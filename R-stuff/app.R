library(shiny) # for webpage creation
library(reactlog)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime) 
library(sortable)

source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data
# tell shiny to log all reactivity
reactlog_enable()


ui <- fluidPage(
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    source('ui/navbar.R')[1],
    div(class = 'tabbable',
        source("ui/home.R")[1],
        source("ui/upload.R")[1],
        source("ui/order.R")[1],
        source("ui/flag.R")[1],
        source("ui/calculate.R")[1],
        source("ui/compare.R")[1]
    ),
    
    includeScript(path = "www/script.js")
  )

server <-  function(input, output, session) {
  
    goop <- reactiveValues()
    goop$combined_df <- combined_df
    
    # Call the server functions from the included files
    source("server/homeserver.R", local = TRUE)
    source("server/uploadserver.R", local = TRUE)
    source("server/orderserver.R", local = TRUE)
    source("server/flagserver.R", local = TRUE)
    source("server/calculateserver.R", local = TRUE)
    source("server/compareserver.R", local = TRUE)
}


shinyApp(ui = ui, server = server)
