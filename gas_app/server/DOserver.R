combined_df <- pivot_wider(combined_df, # this code is problematic in that it doesn't keep ID or flag but for now we're keeping it
                        id_cols = c("Date_Time", "Station"),
                        names_from = Variable,
                        values_from = Value)

combined_df <- combined_df %>%
  filter(!is.na(DO_conc) | !is.na(Temp_C))  #a little cleany cleany
#  mutate(daytime = calc_is_daytime(Date_Time, lat = 35))
  
output$do_date_viewer <- renderUI({
  start_date = min(combined_df$Date_Time)
  end_date = max(combined_df$Date_Time)
  dateRangeInput("date_range_input", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date,
                 min = start_date, max = end_date)
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
  selected_dates <- input$date_range_input
  combined_df <- combined_df%>%
    mutate(daytime = calc_is_daytime(Date_Time, lat = input$latitude))
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2] &
           daytime == TRUE)
})

dark_df <- reactive({
  selected_dates <- input$date_range_input
  combined_df <- combined_df%>%
    mutate(daytime = calc_is_daytime(Date_Time, lat = input$latitude))
  subset(combined_df, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2] &
           daytime == FALSE)
    })

output$light_kernel <- renderPlotly({
  light_data <- light_df() # Retrieve the data frame from reactive light_df
  
  kde <- density(light_data$DO_conc)
  plot <- data.frame(DO = kde$x, Density = kde$y)
  light_plot <- ggplot(plot, aes(x = DO, y = Density)) +
    geom_line() +
    geom_vline(xintercept = input$h_threshold, color = "red") +
    geom_ribbon(data = subset(plot, DO <= input$h_threshold), aes(x = DO, ymin = 0, ymax = Density),
                fill = "darkblue", alpha = 0.3) +
    labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
    ggtitle("Light Kernel Density Estimation")
  
  plotly::ggplotly(light_plot) %>%
    config(displayModeBar = FALSE) # Convert ggplot to Plotly plot
})

output$dark_kernel <- renderPlotly({
    dark_data <- dark_df() # Retrieve the data frame from reactive dark_df
    
    kde <- density(dark_data$DO_conc)
    plot <- data.frame(DO = kde$x, Density = kde$y)
    dark_plot <- ggplot(plot, aes(x = DO, y = Density)) +
      geom_line() +
      geom_vline(xintercept = input$h_threshold, color = "red") +
      geom_ribbon(data = subset(plot, DO <= input$h_threshold), aes(x = DO, ymin = 0, ymax = Density),
                  fill = "darkblue", alpha = 0.3) +
      labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
      ggtitle("Dark Kernel Density Estimation")
    
    plotly::ggplotly(dark_plot) %>%
      config(displayModeBar = FALSE) # Convert ggplot to Plotly plot
  })

output$do_hypoxia_metrics <- renderDT({
  light_df <- light_df()
  dark_df <- dark_df()
  h <- input$h_threshold
  
  light_prob_fxn <- function(light_df, h) {
    n_light <- nrow(light_df)
    hypoxic_n_light <- sum(light_df$DO_conc < h, na.rm = TRUE) #gets number of hypoxic observations
    light_prob_dens <- (hypoxic_n_light/n_light)
  }
  
  dark_prob_fxn <- function(dark_df, h) {
    view(dark_df)
    n_dark <- nrow(dark_df)
    hypoxic_n_dark <- sum(dark_df$DO_conc < h, na.rm = TRUE)
    dark_prob_dens <<- (hypoxic_n_dark/n_dark)
  }
  
  night_hyp_ratio <- function(dark_prob_dens, light_prob_dens) {
    nhr <<- (dark_prob_dens/light_prob_dens)
    return(nhr)
  }
  
  light_prob_dens <- light_prob_fxn(light_df, h)
  dark_prob_dens <- dark_prob_fxn(dark_df, h)
  nhr <- night_hyp_ratio(dark_prob_dens, light_prob_dens)
  
  hypoxia <- data.hypoxia <- data.frame(
    light_probability = round(light_prob_dens, digits = 4),
    dark_probability = round(dark_prob_dens, digits = 4),
    night_hypoxia_ratio = round(nhr, digits = 4)
  )
  
    datatable(hypoxia, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
  
})

output$durationcurve <- renderText({
  # Modal undersaturation is the most frequently observed state of oxygen depletion 
  # of the system, calculated as 100% saturation minus the most often observed DO saturation 
  # and visually represented as the inflection point on the DO duration plot
  
  df <- filtered_df()
  
  DO_mode <- as.numeric(names(table(df$DO_conc))[which.max(table(df$DO_conc))])
  print("DO Mode")
  print(DO_mode)
  #need to convert to DO sat here but pulling temp/pressure data is so difficult
  modal_DO_undersat <- (1 - DO_mode)
  print("modal DO undersat")
  print(modal_DO_undersat)
  
})

