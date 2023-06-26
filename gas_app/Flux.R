library(shiny)
library(knitr)
library(DT)
library(tidyverse)

ui <- fluidPage(
  titlePanel("Calculate DO Flux"),
  sidebarLayout(
    sidebarPanel(
      fileInput("data_file", "Upload DO Data File (CSV):"),
      numericInput("C_a", "Ambient Concentration (C_a) in mg/L:", value = 0),
      numericInput("K", "Coefficient K:", value = 1),
      actionButton("calculate", "Calculate F")
    ),
    mainPanel(
      style = "background-color: #f8f8f8; padding: 20px;",
      h4("Fluxes Result:"),
      dataTableOutput("output")
    )
  )
)

server <- function(input, output) {
  data <- reactive({
    req(input$data_file)  
    read.csv(input$data_file$datapath, header = F)
  })

  observeEvent(input$calculate, {
    req(input$data_file)  
    req(input$data_file$datapath) 
    req(input$C_a) 
    req(input$K)  
    
    data_df <- data()
    DO <- as.numeric(data_df[-2, 3])  # Convert DO conc column to numeric
    C_a <- as.numeric(input$C_a)  
    K <- as.numeric(input$K)  
    DT <- data_df[-2, 2]
    
    F <- K * (DO - C_a)
    
    result <- data.frame(
      'Date_Time' = DT,
      'DO_Conc_mg/L' = DO,
      'Flux' = F)

     output$output <- renderDataTable({
      datatable(result, options = list(pageLength = 20))
    })
  })
}

shinyApp(ui = ui, server = server)
