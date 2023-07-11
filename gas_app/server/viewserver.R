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
    varViewServer(id = i, variable = i, goop = goop, dateRange = reactive({input$viewDateRange}))
  })
})