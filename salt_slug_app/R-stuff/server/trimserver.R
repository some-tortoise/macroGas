output$station_picker <- renderUI({
  num_station <- unique(goop$combined_df$station)
  num_station <- as.numeric(num_station)
  num_station <- sort(num_station)
  checkboxGroupInput('station_pick', label = "Select station to graph", choices = num_station, selected = num_station)
})

filteredData2 <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station_pick, ]
})

output$trim_plot <- renderPlotly({
  # Generate the plot using ggplot and the filteredData reactive expression
  trim_plot <- plot_ly(data = filteredData2(), type = 'scatter', mode = 'lines', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink2") |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
  trim_plot
})

observeEvent(input$continue_button2, {
  updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel")
})

             
