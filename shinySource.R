library(shiny)
source(
  knitr::purl("salt-slug-practice.Rmd",
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
                                     choices = c("Low Range" = "lr", "Full Range" = "fr", "Temp C" = "tempc")),
                actionButton("run",
                             label = "run")),
      
      mainPanel("Visualization", plotOutput("plotOutput"))
    
  )
  
)

server <- function(input, output){
  #output$plotOutput <- renderPlot()
  
}

shinyApp(ui = ui, server = server)
