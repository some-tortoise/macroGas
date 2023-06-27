observeEvent(input$calculate, {
  req(input$C_a) 
  req(input$K)  
  
  C_a <- as.numeric(input$C_a)  
  K <- as.numeric(input$K)  
  DO <- goop$combined_df$DO_conc_mg_L
  
  Flux <- K * (DO - C_a)
  
  result <- data.frame(
    'Date_Time' = DT,
    'DO_Conc_mg_L' = DO,
    'Flux' = Flux)
  
  output$output <- renderDataTable({
    datatable(result, options = list(pageLength = 20))
  })
})