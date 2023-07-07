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
radioButtons('station', label = '', choices = setNames(num_station, num_station))
})

# Reactive expression for filtered data
filteredData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
})

output$start_datetime_input <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
})

output$end_datetime_input <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("end_datetime", "End Date and Time", value = default_value)
})

# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  p = plot_ly(data = filteredData(), type = 'scatter', mode = 'markers', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      range = c(as.POSIXct(input$start_datetime), as.POSIXct(input$end_datetime)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
  
  event_data("plotly_relayout", source = "main_plot")
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


# Download Clean Data in Longer Format
output$download_longer <- downloadHandler(
  filename = function() {
    "processed_data.csv"
  },
  content = function(file) {
    longer_data <- pivot_longer(
    goop$combined_df,
    cols = c("DO_conc", "Temp_C"),
    names_to = "Variable",
    values_to = "Value"
    )

    write.csv(longer_data, file, row.names = FALSE)
  }
)
