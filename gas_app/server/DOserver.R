combined_df <- pivot_wider(combined_df, 
  names_from = "Variable",
  values_from = "Value"
)

filtered_df <- reactive({
  selected_dates <- input$do_date_viewer
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
})

output$do_plot_range <- renderPlotly({
  plot_ly(filtered_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Conc Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Conc"))
})

output$do_plot_full <- renderPlotly({
  plot_ly(combined_df, x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Conc Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Conc"))
})

