library(shiny)
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
      
      mainPanel(plotOutput("plotOutput"))
    
  )
  
)

server <- function(input, output){
  output$plotOutput <- renderPlot({
    ggplot(data = clean_data_list[[4]], mapping = aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
}

shinyApp(ui = ui, server = server)
