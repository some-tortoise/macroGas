output$station_picker <- renderUI({
  num_station <- unique(goop$combined_df$station)
  num_station <- as.numeric(num_station)
  num_station <- sort(num_station)
  checkboxGroupInput('station_picker', label = "Select station to graph", choices = num_station, selected = num_station)
})

observe({
  goop$trim_stations_df <- goop$combined_df[goop$combined_df$station %in% input$station_picker, ]
}) #creates goop$trim_stations_df from those picked in station_picker

observe({
  goop$trim_xValue <- goop$trim_stations_df$Date_Time
  goop$trim_yValue <- goop$trim_stations_df$Low_Range
}) #creates goop$trim_xValue and goop$trim_Yvalue from DateTime and Low_Range

observe({
    goop$trim_xLeft <- goop$trim_xValue[1] #sets vertical bar to farthest left
    goop$trim_xRight <- goop$trim_xValue[length(goop$trim_xValue) - 1]
})

observe({
  goop$first_trim <- goop$trim_stations_df[(as.numeric(goop$trim_xValue) >= as.numeric(goop$trim_xLeft)) & (as.numeric(goop$trim_xValue) <= as.numeric(goop$trim_xRight)), ]
}) #creates goop$trimmed_slug based on goop$calc_curr_station_df that only contains values between the left and right bars (calc_xLeft and calc_xRight)


output$trim_plot <- renderPlotly({
  # Generate the plot using ggplot and the filteredData reactive expression
  req(goop$trim_stations_df)
  req(goop$trim_xLeft)
  req(goop$trim_xRight)
  
  trim_xVal <- goop$trim_stations_df$Date_Time
  trim_yVal <- goop$trim_stations_df$Low_Range
  trim_xLeft <- goop$trim_xLeft
  trim_xRight <- goop$trim_xRight
  
  goop$trim_stations_df$xfill <- ifelse(
    as.numeric(trim_xVal) > as.numeric(trim_xLeft) & as.numeric(trim_xVal) < as.numeric(trim_xRight),
    trim_xVal,
    NA
  )
  
  trim_xLeft <- as.POSIXct(trim_xLeft, tz = 'GMT', origin = "1970-01-01")
  trim_xRight <- as.POSIXct(trim_xRight, tz = 'GMT', origin = "1970-01-01")
  
  
  #super fun error-checking courtesy of chatgpt
  print("Trim X Left in renderPlotly:")
  print(trim_xLeft)
  print("Trim X Right in renderPlotly:")
  print(trim_xRight)
  
  trim_plot <- plot_ly(data = goop$trim_stations_df, type = 'scatter', mode = 'lines', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink2") |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
  trim_plot
  
  # trim_plot <- plot_ly(goop$trim_stations_df, type = 'scatter', mode = 'lines', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink2") %>%
  #   layout(plot_bgcolor = 'white', xaxis = list(title = 'Date Time')
  #   )
  
  trim_plot
  
})

observeEvent(input$continue_button2, {
  updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel")
})

             
