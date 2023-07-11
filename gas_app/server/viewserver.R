filteredData <- reactive({
  df_plot_view <- goop$combined_df[goop$combined_df$Station %in% input$Station, ]
  selected_dates_view <- input$viewDateRange
  subset(df_plot_view, Date_Time >= selected_dates_view[1] & Date_Time <= selected_dates_view[2])
})

output$main_plot <- renderPlotly({
  plot_df_view = filteredData() %>% filter(Variable == input$variable_choice)
  plot_ly(data = plot_df_view, type = 'scatter', mode = 'markers', 
          x = ~Date_Time, y = ~Value, key = ~(paste0(as.character(id),"_",as.character(Station))), color = ~as.character(Station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = input$variable_choice))
})


observe({
  lapply(unique(goop$combined_df$Variable), function(i) {
    varContainerServerView(id = i, variable = i, goop = goop)
  })
})