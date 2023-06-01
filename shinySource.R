library(shiny)
source(
  knitr::purl("stuff.R",
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel("Our App"),
    
    sidebarLayout(
      sidebarPanel("Date",
                  dateInput("dateInput", 
                            label = "Write Date Here", 
                            value = "2023-05-25",
                            format = "yyyy/mm/dd"),
                radioButtons("radioInput",
                                     label = "Y Axis",
                                     choices = c("Low Range", "Full Range" = "fr", "Temp C" = "tempc")),
                actionButton("run",
                             label = "run")),
      
      mainPanel("Visualization", plotOutput("plotOutput"))
    
  )
  
)

server <- function(input, output){
  output$plotOutput <- renderPlot({
    ggplot(clean_data_list[[1]][clean_data_list[[1]]$Date==as.Date(input$dateInput), ], aes(x = Time, y = Temp_C)) +
      geom_point() +
      geom_line() 
  })
  
}

shinyApp(ui = ui, server = server)
