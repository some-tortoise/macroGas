library(shiny)
library(DT)

ui <- fluidPage(
  fileInput(inputId = 'csvs', 
            label = 'Choose!',
            multiple = TRUE),
  selectInput(inputId = 'select',
              label = 'Select',
              choices = c()),
  DT::dataTableOutput('dt')
)

server <- function(input, output, session){
  
  uploaded_data <- reactiveValues(names = NULL, data = NULL)
  
  observeEvent(input$csvs, {
    seq_csv <- seq(1, length(input$csvs$name))
    prev_num_files <- length(uploaded_data$data)
    in_file <- NULL
    for(i in seq_csv){
      tryCatch({
        in_file <- read.csv(input$csvs$datapath[i])
      }, error = function(e){
        in_file <- NULL
      })
      
      uploaded_data$names[[prev_num_files + i]] <- input$csvs$name[i]
      uploaded_data$data[[prev_num_files + i]] <- as.data.frame(in_file)
      
    }
    
    updateSelectInput(session, 'select', choices = uploaded_data$names)
  })
  
  output$dt <- renderDT({
    val <- 1
    for(i in seq(uploaded_data$names)){
      if(input$select == uploaded_data$names[i]){
        val <- i
      }
    }
    datatable(uploaded_data$data[[val]])
  })
  
}

shinyApp(ui = ui, server = server)