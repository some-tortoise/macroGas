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
        source("ui/law_and_order.R")[1],
        source("ui/flag.R")[1],
        source("ui/calculate.R")[1],
        source("ui/visualize.R")[1]
    ),
    includeScript(path = "www/script.js")
  )


source("server/homeserver.R")
source("server/uploadserver.R")
source("server/flagserver.R")
#source("server/law_and_order_server.R")
server <-  function(input, output, session) {
    # Call the server functions from the included files
    homeserver(input, output, session)
    uploadserver(input, output, session)
    flagserver(input, output, session)
    #law_and_order_server(input, output, session)
  }


shinyApp(ui = ui, server = server)
