library(shiny)

ui <- fluidPage(
  fileInput(inputId = 'csvs', 
            label = 'Choose!',
            multiple = TRUE)
)

server <- function(input, output){
  
  uploaded_data <- reactiveValues(data = NULL)
  
  observeEvent(input$csvs, {
    seq_csv <- seq(1, length(input$csvs$name))
    for(i in seq_csv){
      in_file <- read.csv(input$csvs$datapath[i])
      
      uploaded_data$data <- c(uploaded_data$data, 
                              c(input$csvs$name[i], 
                                in_file)
                              )
    }
    
    print(uploaded_data$data)
    print('---------------------------------------')
  })
}

shinyApp(ui = ui, server = server)