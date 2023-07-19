combined_df <- pivot_wider(combined_df, # this code is problematic in that it doesn't keep ID or flag but for now we're keeping it
                        id_cols = c("Date_Time", "Station"),
                        names_from = Variable,
                        values_from = Value)

combined_df <- combined_df %>%
  filter(!is.na(DO_conc) | !is.na(Temp_C)) # a little cleany cleany

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
    Hypoxia_Prob = sum(combined_df$DO_conc <= input$h_threshold, na.rm = TRUE)/(length(combined_df$DO_conc))
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
    Hypoxia_Prob = sum(metrics_df$DO_conc <= input$h_threshold, na.rm = TRUE)/(length(metrics_df$DO_conc))
  )
  datatable(metrics, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
})


light_df <- reactive({
  view(combined_df)
  selected_dates <- input$date_range_input
  sunrise_time <- input$sunrise
  sunset_time <- input$sunset
  
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2] &
           (hour(Date_Time) > hour(sunrise_time) | 
              (hour(Date_Time) == hour(sunrise_time) & minute(Date_Time) >= minute(sunrise_time))) &
           (hour(Date_Time) < hour(sunset_time) | 
              (hour(Date_Time) == hour(sunset_time) & minute(Date_Time) <= minute(sunset_time))))
  

})

dark_df <- reactive({
  light <- light_df()
  view(light)
  dark <- subset(combined_df, !(Date_Time %in% light$Date_Time))
  view(dark)
})

output$light <- renderPlotly({
  plot_ly(light_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines")
})

output$dark <- renderPlotly({
  plot_ly(dark_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines")
})

output$do_hypoxia_metrics <- renderDT({
  light_df <- light_df()
  dark_df <- dark_df()
  h <- input$h_threshold
  
  light_prob_fxn <- function(light_df, h) {
    view(light_df)
    n_light <- nrow(light_df)
    print(n_light)
    hypoxic_n_light <- sum(light_df$DO_conc < h, na.rm = TRUE) #gets number of hypoxic observations
    print(hypoxic_n_light)
    light_prob_dens <- (hypoxic_n_light/n_light)
  }
  
  dark_prob_fxn <- function(dark_df, h) {
    n_dark <- nrow(dark_df)
    hypoxic_n_dark <- sum(dark_df$DO_conc < h, na.rm = TRUE)
    dark_prob_dens <<- (hypoxic_n_dark/n_dark)
    print("Dark probability density")
    print(dark_prob_dens)
  }
  
  night_hyp_ratio <- function(dark_prob_dens, light_prob_dens) {
    nhr <<- (dark_prob_dens/light_prob_dens)
    return(nhr)
  }
  
  
  light_prob_dens <- light_prob_fxn(light_df, h)
  dark_prob_dens <- dark_prob_fxn(dark_df, h)
  nhr <- night_hyp_ratio(dark_prob_dens, light_prob_dens)
  
  hypoxia <- data.frame( 
    sunrise = format(input$sunrise, "%H:%M"),
    sunset = format(input$sunset,"%H:%M"),
    light_probability = light_prob_dens,
    dark_probability = dark_prob_dens,
    night_hypoxia_ratio = nhr
  )    
    datatable(hypoxia, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
  
})




