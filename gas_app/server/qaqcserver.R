selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
  df_chosen <- df_plot[((paste0(df_plot$Date_Time,'_',df_plot$station) %in% event.click.data$key) | 
                          (paste0(df_plot$Date_Time,'_',df_plot$station) %in% event.selected.data$key)),]
  df_chosen <- df_chosen[df_chosen$variable == input$variable_choice,]
  return(df_chosen)
}) 

output$variable_c <- renderUI({
  radioButtons("variable_choice",label = helpText('Select variable to graph'),
               choices = unique(goop$combined_df$variable))
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
  plot_ly(data = filteredData()[goop$combined_df$variable == input$variable_choice,], type = 'scatter', mode = 'markers', 
              x = ~Date_Time, y = ~value, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      range = c(as.POSIXct(input$start_datetime), as.POSIXct(input$end_datetime)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = input$variable_choice))
})

output$selected_data_table <- renderDT({
  datatable(selectedData() %>% select(-c(id)), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
})

observeEvent(input$flag_btn, {
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)), "Flag"] <- input$flag_type  # Set the flag
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
