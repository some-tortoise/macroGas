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