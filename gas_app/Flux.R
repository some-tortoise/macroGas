
library(shiny)
library(knitr)
library(DT)
library(tidyverse)

ui <- fluidPage(
  titlePanel("Calculate Flux"),
  sidebarLayout(
    sidebarPanel(
      fileInput("data_file", "Upload DO Data File (CSV):"),
      numericInput("C_a", "Ambient Concentration (C_a):", value = 0),
      numericInput("K", "Factor (K):", value = 1),
      actionButton("calculate", "Calculate F")
    ),
    mainPanel(
      style = "background-color: #f8f8f8; padding: 20px;",
      h4("Result:"),
      dataTableOutput("output")
    )
  )
)


server <- function(input, output) {
  data <- reactive({
    req(input$data_file)  
    read.csv(input$data_file$datapath)
  })

  observeEvent(input$calculate, {
    req(input$data_file)  
    req(input$data_file$datapath) 
    req(input$C_a) 
    req(input$K)  
    
    data_df <- data()
    C_g <- as.numeric(data_df[, 3])  # Convert DO column to numeric
    C_a <- as.numeric(input$C_a)  
    K <- as.numeric(input$K)  
    
    F <- K * (C_g - C_a)
    
    result <- data.frame(C_g, F)  # Create a data frame with C_g and F

     output$output <- renderDataTable({
      datatable(result, options = list(pageLength = 10))
    })
  })
}

shinyApp(ui = ui, server = server)

