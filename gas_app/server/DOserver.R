combined_df <- pivot_wider(combined_df, 
  names_from = "Variable",
  values_from = "Value"
)

output$do_date_viewer <- renderUI({
  start_date = min(combined_df$Date_Time)
  end_date = max(combined_df$Date_Time)
  dateRangeInput("date_range_input", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date)
})

filtered_df <- reactive({
  selected_dates <- input$date_range_input
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
})

output$do_plot_range <- renderPlotly({
  plot_ly(filtered_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Conc"))
})

output$do_plot_full <- renderPlotly({
  plot_ly(combined_df, x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Conc"))
})

output$do_metrics_full <- renderDT({
  metrics_dt <-  data.frame(
    Mean = mean(combined_df$DO_conc, na.rm = TRUE),
    Minimum = min(combined_df$DO_conc, na.rm = TRUE),
    Maximum = max(combined_df$DO_conc, na.rm = TRUE),
    Amplitude = max(combined_df$DO_conc, na.rm = TRUE) - min(combined_df$DO_conc, na.rm = TRUE),
    Hypoxia_Prob = sum(combined_df$DO_conc <= 9, na.rm = TRUE)/(length(combined_df$DO_conc))
  )
  datatable(metrics_dt, options = list(rownames = FALSE, searching = FALSE, paging = FALSE, info = FALSE, ordering = FALSE))
 })
output$do_metrics_range <- renderDT({
  metrics_df <- filtered_df()
  metrics <- data.frame(
    Mean = mean(metrics_df$DO_conc, na.rm = TRUE),
    Minimum = min(metrics_df$DO_conc, na.rm = TRUE),
    Maximum = max(metrics_df$DO_conc, na.rm = TRUE),
    Amplitude = max(metrics_df$DO_conc, na.rm = TRUE) - min(metrics_df$DO_conc, na.rm = TRUE),
    Hypoxia_Prob = sum(metrics_df$DO_conc <= 9, na.rm = TRUE)/(length(metrics_df$DO_conc))
  )
  datatable(metrics, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
})