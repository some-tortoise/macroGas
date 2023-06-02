library(shiny)
library(plotly)
source(
  knitr::purl("stuff.R",
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel("Salt Slug Visualizations"),
    
    sidebarLayout(
      sidebarPanel("",
                radioButtons("radioInput",
                             label = helpText('Select variable to graph'),
                             choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
    ),
      
      mainPanel(plotlyOutput("plotOutput"))
    
  )
  
)

server <- function(input, output){
  output$plotOutput <- renderPlotly({
    p <- ggplot(data = clean_data_list[[4]], mapping = aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
    ggplotly(p)
  })
}

shinyApp(ui = ui, server = server)
