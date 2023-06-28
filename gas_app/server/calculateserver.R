observeEvent(input$calculate, {
  req(input$C_a) 
  req(input$K)  
  
  C_a <- as.numeric(input$C_a)  
  K <- as.numeric(input$K)  
  DO <- as.numeric(goop$combined_df$DO_conc_mg_L)
  
  Flux <- K * (DO - C_a)
  
  result <- data.frame(
    'Date_Time' = goop$combined_df$Date_Time,
    'DO_Conc_mg_L' = DO,
    'Flux' = Flux)
  
  mean_result <- data.frame(
    "Mean_DO" = mean(DO),
    "Mean_Flux" = mean(Flux)
    )
  
output$results <- renderDataTable({
    datatable(result, options = list(pageLength = 5, searching = FALSE))
  })
 
output$mean_results <- renderDataTable({
      datatable(mean_result, options = list(pageLength = 1, paging = FALSE, searching = FALSE))
  })
})