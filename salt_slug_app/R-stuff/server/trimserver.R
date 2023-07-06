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
  print("Trim_xLeft in renderPlotly:")
  print(trim_xLeft)
  print("Trim_xRight in renderPlotly:")
  print(trim_xRight)
  
  plot <- plot_ly(data = goop$trim_stations_df, type = 'scatter', mode = 'lines', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.5, source = "imgLink2") %>%
    #add_trace(x = ~Date_Time, y = ~Low_Range) %>%
    #add_trace(x = c(trim_xLeft, trim_xRight), y = c(NA, NA), line = list(color = 'rgba(0, 0, 0, 0)', width = 0), fill = 'tonextx', fillcolor = 'rgba(255, 165, 0, 0.3)') %>%
     layout(plot_bgcolor='white', xaxis = list(title = 'Date Time')) # shapes = list(
      # list(type = "line", x0 = trim_xLeft, x1 = trim_xLeft,
      #      y0 = 0, y1 = 1, yref = "paper"),
      # list(type = "line", x0 = trim_xRight, x1 = trim_xRight,
      #      y0 = 0, y1 = 1, yref = "paper")
 #   )) %>%
    # config(edits = list(shapePosition = TRUE))
  
  #event_data <- event_data("plotly_relayout", source = "trim_plot")
  #plot <- plot %>% event_register("plotly_relayout")
  plot
  
})

# observeEvent(event_data("plotly_relayout"), {
#   ed <- event_data("plotly_relayout")
#   shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
#   if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
#   barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
#   if(is.na(barNum)){ return() } # just some secondary error checking to see if we got any NAs. This line should never be called
#   row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # get shape number
#   pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'GMT', origin = "1970-01-01")
#   
#   if(barNum == 0){
#     goop$trim_xLeft <- 0
#     goop$trim_xLeft <- pts[1]
#   }else{
#     goop$trim_xRight <- 0
#     goop$trim_xRight <- pts[1]
#   }
# })


observeEvent(input$continue_button2, {
  updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel")
})

             
