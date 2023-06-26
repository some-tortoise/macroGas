library(shiny)
library(plotly)
source(
  knitr::purl("stuff.R",
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel("Salt Slug Visualizations"),
    
    sidebarLayout(
      sidebarPanel(
        selectInput('station', label = 'select the station', c('All', 1, 2, 3, 4, 5)),
        radioButtons("radioInput",label = helpText('Select variable to graph'),
                     choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C'))
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
  
  # output$plotOutput <- renderPlot({
  #   if(input$station=='All'){
  #     avg_df = combined_df |>
  #       group_by(Date_Time) |>
  #       summarise(Low_Range = mean(Low_Range),
  #                 Full_Range = mean(Full_Range),
  #                 Temp_C = mean(Temp_C))
  #     ggplot(data = avg_df, aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
  #       theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
  #       geom_point() +
  #       geom_line() +
  #       labs(x = 'Time', y = input$radioInput)
  #   }
  #   else{
  #     ggplot(data = clean_data_list[[as.numeric(input$station)]], mapping = aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
  #       theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
  #       geom_point() +
  #       geom_line() +
  #       labs(x = 'Time', y = input$radioInput)
  #   }
  #})
  
  
}

shinyApp(ui = ui, server = server)
