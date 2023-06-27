selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
  df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                          (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]
  return(df_chosen)
}) 

output$station <- renderUI({
  num_station <- unique(goop$combined_df$station)
  radioButtons('Station', label = '', num_station) 
})

# Reactive expression for filtered data
filteredData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
})


# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  # unique_station = unique(goop$combined_df$station)
  # rainbow_color = rainbow(length(unique_station))
  # color_mapping <- c()
  # for(i in seq(unique_station)){
  #   color_mapping[as.character(i)] <- rainbow_color[i]
  # }
  p = plot_ly(data = filteredData(), type = 'scatter', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      range = c(as.POSIXct(input$start_datetime), as.POSIXct(input$end_datetime)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
  p = event_register(p, 'plotly_relayout')
  p
})

output$selected_data_table <- renderDT({
  datatable(selectedData(), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
})

observeEvent(input$flag_btn, {
  flag_name <- paste0(input$variable_choice, "_Flag")
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)), flag_name] <- input$flag_type  # Set the flag
})
