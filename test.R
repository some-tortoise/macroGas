library(shiny)
library(shinyTime)

ui <- fluidPage(
  
  titlePanel("shinyTime Example App"),
  
  sidebarLayout(
    sidebarPanel(
      timeInput("time_input", "Enter time", value = strptime("12:34:56", "%T"))
    ),
    
    mainPanel(
      textOutput("time_output")
    )
  )
)

server <- function(input, output, session) {
  output$time_output <- renderText(strftime(input$time_input, "%T"))
}

shinyApp(ui, server)