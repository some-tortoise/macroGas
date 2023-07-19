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

output$station <- renderUI({
  station_names <- unique(goop$combined_df$Station)
  radioButtons('station', label = "Select station to graph", station_name)
})

output$site <- renderUI({
  site_name <- unique(goop$combined_df$Site)
  radioButtons('site', label = "Select site to graph", site_name)
})

filtered_df <- reactive({
    df_plot <- goop$combined_df[goop$combined_df$Station %in% input$station, ]
    df_chosen <- df_plot[paste0(df_plot$Date_Time,'_',df_plot$Station) %in% event.selected.data$key,]
    df_chosen <- df_chosen[df_chosen$Variable == input$variable_choice,]
    return(df_chosen)
  selected_dates <- input$date_range_input
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
})

output$do_plot_range <- renderPlotly({
  plot_ly(filtered_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Concentration (mg/L)"))
})

output$do_plot_full <- renderPlotly({
  plot_ly(combined_df, x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Concentration (mg/L)"))
})

output$do_metrics_full <- renderDT({
  metrics_dt <-  data.frame(
    Mean = mean(combined_df$DO_conc, na.rm = TRUE),
    Minimum = min(combined_df$DO_conc, na.rm = TRUE),
    Maximum = max(combined_df$DO_conc, na.rm = TRUE),
    Amplitude = max(combined_df$DO_conc, na.rm = TRUE) - min(combined_df$DO_conc, na.rm = TRUE),
    Hypoxia_Prob = sum(combined_df$DO_conc <= input$hypoxia_math, na.rm = TRUE)/(length(combined_df$DO_conc))
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
    Hypoxia_Prob = sum(metrics_df$DO_conc <= input$hypoxia_math, na.rm = TRUE)/(length(metrics_df$DO_conc))
  )
  datatable(metrics, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
})