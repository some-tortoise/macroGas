output$station_picker <- renderUI({
  num_station <- unique(goop$combined_df$station)
  checkboxGroupInput('station_picker', label = "Select station to graph", num_station)
})

filteredData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station_picker, ]
})

output$trim_plot <- renderPlotly({
  # Generate the plot using ggplot and the filteredData reactive expression
  trim_plot <- plot_ly(data = filteredData(), type = 'scatter', mode = 'line', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink")
  trim_plot
})