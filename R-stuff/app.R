library(shiny) # for webpage creation
library(reactlog)

# tell shiny to log all reactivity
reactlog_enable()


shinyApp(ui = ui, server = server)

# once app has closed, display reactlog from shiny
shiny::reactlogShow()