titlePanel("Calculate DO Flux")
sidebarLayout(
  sidebarPanel(
    numericInput("C_a", "Ambient Concentration (C_a) in mg/L:", value = 0),
    numericInput("K", "Coefficient K:", value = 1),
    actionButton("calculate", "Calculate  Flux, Mean DO and Flux") 
  ),
  mainPanel(
    style = "background-color: #f8f8f8; padding: 20px;",
    h4("Results:"),
    dataTableOutput("results"),
    dataTableOutput("mean_results")
  )
)
