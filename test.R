library(shiny)

df <- data.frame(
  station = c(1,1,1,2,2,2,3,3,3),
       x = c(1,2,3,1,2,3,1,2,3),
       y = c(1,2,3,5,5,5,9,8,7)
  )

color_mapping <- c('1' = 'red', '2' = 'blue', '3' = 'green')

ui <- fluidPage(
  plotOutput('plot'),
  actionButton('b', 'change station order')
)

server <- function(input, output, session) {
  
  data <- reactiveValues(df = combined_df)
  
  output$plot <- renderPlot({
    ggplot(data$df, aes(x = x, y = y, color = as.character(station))) + 
      geom_line() + 
      scale_color_manual(values = color_mapping)
  })
  
  observeEvent(input$b, {
    print('DF Before: ')
    print(data$df)
    data$df$station = c(3,3,3,1,1,1,2,2,2)
    print('')
    print('')
    print('DF After: ')
    print(data$df)
  })
}

shinyApp(ui, server)