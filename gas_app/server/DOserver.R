# Modal dialog that gives an error message if there is no DO data present when the tab is opened
observeEvent(input$navbar, {
  if (input$navbar == "DO" & !("DO_conc" %in% goop$combined_df$Variable)) {
    showModal(modalDialog(
      p("You need to upload data with dissolved oxygen (DO) concentration data prior to proceeding to this page."),
      title = "Upload DO Data", footer = modalButton("Dismiss"), size = "l"
    ))
  }
})

#
# ALL UI AND DO CALCULATIONS 
#

observeEvent(goop$combined_df,{

# Only runs all the calculations if DO_conc exists to avoid errors
  if("DO_conc" %in% goop$combined_df$Variable){

#
# UI
#

# A renderUI that allows users to select from the uploaded dates
output$do_date_viewer <- renderUI({
  if(is.null(goop$combined_df)) return(NULL)
  start_date = min(goop$combined_df$Date_Time)
  end_date = max(goop$combined_df$Date_Time)
  dateRangeInput("date_range_input", "Select Date(s) To View/Calculate",
                 start = start_date, end = end_date, min = start_date, max = end_date)
})

# renderUIs to select site and stations that are present
output$DOSiteStationSelects <- renderUI({
    selectInput('DOSiteSelect', "Select Site", unique(goop$combined_df$Site))
    selectInput('DOStationSelect', 'Select Station', unique(goop$combined_df$Station))
})

#
# DATA FORMATTING
#

# Pivot combined_df to wide format for later use in "Full Range" metrics
combined_df <- reactive({
  
  # Assign the data to combined_df based on which station is selected
  combined_df <- goop$combined_df[goop$combined_df$Station %in% input$DOStationSelect, ]
  combined_df_pivoted <- pivot_wider(combined_df,
                            id_cols = c("Date_Time", "Station", "Site"),
                            names_from = Variable,
                            values_from = Value)
  
  # view(combined_df_pivoted)
  
})

# Create reactive filtered_df for later use in "Selected Range" metrics
filtered_df <- reactive({
  if(is.null(goop$combined_df)) return(NULL)
  # Assign the data to df_plot based on which station is selected
  df_plot <- goop$combined_df[goop$combined_df$Station %in% input$DOStationSelect, ]
  df_pivoted <- pivot_wider(df_plot,
                              id_cols = c("Date_Time", "Station", "Site"),
                              names_from = Variable,
                              values_from = Value)
  
  # Trim the pivoted data frame to those selected by the user
  selected_dates <- input$date_range_input
  df_pivoted <- subset(df_pivoted, Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
  
  })

#
# DO DATA PLOTS
#

# Render the plot of the full range DO data (from combined_df)
output$do_plot_full <- renderPlotly({
  if(is.null(combined_df()$DO_conc)) return()
  plot_ly(combined_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Concentration (mg/L)"))
})

# Render the plot of the selected range DO data (from filtered_df)
output$do_plot_range <- renderPlotly({
  if(is.null(filtered_df()$DO_conc)) return()
  plot_ly(filtered_df(), x = ~Date_Time, y = ~DO_conc, type = "scatter", mode = "lines") %>%
    layout(title = "DO Concentration Over Time", xaxis = list(title = "Date and Time"), yaxis = list(title = "DO Concentration (mg/L)"))
})

# 
# SELECTED RANGE METRICS
#

output$do_metrics_range <- renderDT({
  metrics_df <- filtered_df()
  if(is.null(metrics_df) || !('DO_conc' %in% colnames(metrics_df))) {
    return(datatable(data.frame(Mean = c(), Minimum = c(), Maximum = c(), Aplitude = c(), Hypoxia_Prob = c()), options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE)))
  }
  metrics <- data.frame(
    Mean = round(mean(metrics_df$DO_conc, na.rm = TRUE), 4),
    Minimum = round(min(metrics_df$DO_conc, na.rm = TRUE), 4),
    Maximum = round(max(metrics_df$DO_conc, na.rm = TRUE), 4),
    Amplitude = round(max(metrics_df$DO_conc, na.rm = TRUE) - min(metrics_df$DO_conc, na.rm = TRUE), 4),
    Hypoxia_Prob = round(sum(metrics_df$DO_conc <= input$h_threshold, na.rm = TRUE)/(length(metrics_df$DO_conc)), 4)
  )
  datatable(metrics, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))
}) #renders a datatable with DO metrics for selected dates

# 
# FULL RANGE METRICS
#

output$do_metrics_full <- renderDT({
  combined_df <- combined_df()
  if(is.null(combined_df) || !('DO_conc' %in% colnames(combined_df))) {
    return(datatable(data.frame(Mean = c(), Minimum = c(), Maximum = c(), Aplitude = c(), Hypoxia_Prob = c()), options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE)))
  }
  metrics_dt <-  data.frame(
    Mean = round(mean(combined_df$DO_conc, na.rm = TRUE), 4), 
    Minimum = round(min(combined_df$DO_conc, na.rm = TRUE), 4),
    Maximum = round(max(combined_df$DO_conc, na.rm = TRUE), 4),
    Amplitude = round(max(combined_df$DO_conc, na.rm = TRUE) - min(combined_df$DO_conc, na.rm = TRUE), 4),
    Hypoxia_Prob = round(sum(combined_df$DO_conc <= input$h_threshold, na.rm = TRUE)/(length(combined_df$DO_conc)), 4)
  )
  datatable(metrics_dt, options = list(rownames = FALSE, searching = FALSE, paging = FALSE, info = FALSE, ordering = FALSE))
 })

observe({
  req(input$date_range_input)
  selected_dates <- input$date_range_input
  
  api_url <- paste0("https://archive-api.open-meteo.com/v1/archive?",
                    "latitude=",input$latitude,
                    "&longitude=-79.004672",
                    "&start_date=", selected_dates[1],
                    "&end_date=", selected_dates[2],
                    "&hourly=is_day")
  
  
  res <- GET(api_url)
  apiData <- as.data.frame(fromJSON(rawToChar(res$content)))
  
  for(i in 1:nrow(apiData)){
    apiData[i, 'Date'] <- str_split(apiData[i, 'hourly.time'], 'T')[[1]][1]
    apiData[i, 'Time'] <- str_sub(str_split(apiData[i, 'hourly.time'], 'T')[[1]][2], 0,2)
  }
  
  goop$daytime_df <- data.frame(
    Date = apiData['Date'],
    Time = apiData['Time'],
    hourly.is_day = apiData['hourly.is_day']
  )
})


is_daytime <- function(day){
  
  dayDate <- str_split(day, ' ')[[1]][1]
  if(length(str_split(day, ' ')[[1]]) == 1){
    dayHour <- '00'
  }else{
    dayHour <- str_sub((str_split(day, ' ')[[1]][2]),0,2)
  }
  
  for(i in 1:nrow(goop$daytime_df)){
    if(goop$daytime_df[i,'Date'] == dayDate & goop$daytime_df[i,'Time'] == dayHour){
      if(goop$daytime_df[i,'hourly.is_day'] == '1'){
        return(TRUE)
      }
    }
  }
  return(FALSE)
}

#
# NHR/HYPOXIA METRICS
#

# Create data frame of only daytime values using calc_is_daytime
light_df <- reactive({
  
  selected_dates <- input$date_range_input
  
  hyp_combined_df <- subset(combined_df(), Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
  dates <- as.vector(as.character(hyp_combined_df$Date_Time))
  for(i in 1:length(dates)){
    hyp_combined_df[i,'daytime'] <- is_daytime(dates[i])
  }
  
  # select only points where the daytime column is true
  light_combined_df <- subset(hyp_combined_df, daytime == TRUE) 
})

# Create data frame of only nighttime values using calc_is_daytime
dark_df <- reactive({
  selected_dates <- input$date_range_input

  hyp_combined_df <- subset(combined_df(), Date_Time >= selected_dates[1] & Date_Time <= selected_dates[2])
  dates <- as.vector(as.character(hyp_combined_df$Date_Time))
  for(i in 1:length(dates)){
    hyp_combined_df[i,'daytime'] <- is_daytime(dates[i])
  }
  
  # select only points where the daytime column is false
  dark_combined_df <- subset(hyp_combined_df, daytime == FALSE)
  #if(nrow(dark_combined_df) == 0) dark_combined_df <- NULL

})

#
# Daytime Kernel Density Estimation Plot
#

output$light_kernel <- renderPlot({
  light_data <- light_df() # Retrieve the data frame from reactive light_df
  if(is.null(light_data) || !('DO_conc' %in% colnames(light_data))) return()
  kde <- density(light_data$DO_conc)
  plot <- data.frame(DO = kde$x, Density = kde$y)
  light_plot <- ggplot(plot, aes(x = DO, y = Density)) +
    geom_line() +
    geom_vline(xintercept = input$h_threshold, color = "red") +
    geom_ribbon(data = subset(plot, DO <= input$h_threshold), aes(x = DO, ymin = 0, ymax = Density),
                fill = "darkblue", alpha = 0.3) +
    labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
    ggtitle("Light Kernel Density Estimation")
  
  # Return ggplot object
  light_plot
  
})

#
# Nighttime Kernel Density Estimation Plot
#

output$dark_kernel <- renderPlot({
    dark_data <- dark_df() # Retrieve the data frame from reactive dark_df
    if(is.null(dark_data) || !('DO_conc' %in% colnames(dark_data))) return()
    kde <- density(dark_data$DO_conc)
    plot <- data.frame(DO = kde$x, Density = kde$y)
    dark_plot <- ggplot(plot, aes(x = DO, y = Density)) +
      geom_line() +
      geom_vline(xintercept = input$h_threshold, color = "red") +
      geom_ribbon(data = subset(plot, DO <= input$h_threshold), aes(x = DO, ymin = 0, ymax = Density),
                  fill = "darkblue", alpha = 0.3) +
      labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
      ggtitle("Dark Kernel Density Estimation")
    
    # Return ggplot object
    dark_plot
})

#
# HYPOXIA CALCULATIONS
#

output$do_hypoxia_metrics <- renderDT({
 
# Inputs: 
  light_df <- light_df()
  dark_df <- dark_df()
  h <- input$h_threshold # user inputs the hypoxia threshold

  #
  # FUNCTIONS
  #
  
  # Use daytime dataframe to calcluate the light probability density
  light_prob_fxn <- function(light_df, h) {
    n_light <- nrow(light_df)
    if(is.null(light_df)) return()
    hypoxic_n_light <- sum(light_df$DO_conc < h, na.rm = TRUE) 
    light_prob_dens <- (hypoxic_n_light/n_light)
  }

  # Use nighttime dataframe to calcluate the light probability density
  dark_prob_fxn <- function(dark_df, h) {
    n_dark <- nrow(dark_df)
    if(is.null(dark_df)) return()
    hypoxic_n_dark <- sum(dark_df$DO_conc < h, na.rm = TRUE)
    dark_prob_dens <<- (hypoxic_n_dark/n_dark)
  }

  # Divide dark by light probability density to get night hypoxia ratio
  night_hyp_ratio <- function(dark_prob_dens, light_prob_dens) {
    nhr <<- (dark_prob_dens/light_prob_dens)
    return(nhr)
  }

  # run the functions 
  light_prob_dens <- light_prob_fxn(light_df, h)
  dark_prob_dens <- dark_prob_fxn(dark_df, h)
  nhr <- night_hyp_ratio(dark_prob_dens, light_prob_dens)

  # assign results to hypoxia dataframe 
  hypoxia <- data.hypoxia <- data.frame(
    light_probability = round(light_prob_dens, digits = 4),
    dark_probability = round(dark_prob_dens, digits = 4),
    night_hypoxia_ratio = round(nhr, digits = 4)
  )

  # display the hypoxia dataframe
  datatable(hypoxia, options = list(rownames = FALSE, searching = FALSE, paging = FALSE,  info = FALSE, ordering = FALSE))

})

}
  
})

