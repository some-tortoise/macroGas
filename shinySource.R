library(shiny)
source(
  knitr::purl("stuff.R",
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel("Our App"),
    
    sidebarLayout(
      sidebarPanel("",
                radioButtons("radioInput",
                                     label = "Y Axis",
                                     choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
    ),
      
      mainPanel("Visualization", plotOutput("plotOutput"))
    
  )
  
)

server <- function(input, output){
  output$plotOutput <- renderPlot({
    ggplot(data = clean_data_list[[4]], mapping = aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'green')) +
      geom_point() +
      geom_line() 
  })
  
}

shinyApp(ui = ui, server = server)
