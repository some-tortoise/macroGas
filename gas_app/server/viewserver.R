output$varViewContainers <- renderUI({
  vars <- unique(goop$combined_df$Variable)
  LL <- vector("list",length(vars))       
  for(i in vars){
    LL[[i]] <- list(varViewUI(id = i, var = i))
  }      
  return(LL)  
})


observe({
  lapply(unique(goop$combined_df$Variable), function(i) {
    varViewServer(id = i, variable = i, goop = goop, dateRange = reactive({input$date_range_input_view}))
  })
})

output$viewDateRange <- renderUI({
  start_date = min(combined_df$Date_Time)
  end_date = max(combined_df$Date_Time)
  dateRangeInput("date_range_input_view", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date)
})