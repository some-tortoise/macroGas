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

goop$suspended <- TRUE

output$trim_plot <- renderPlotly({
  req(goop$trim_xLeft)
  trim_xLeft <- as.POSIXct(goop$trim_xLeft, tz = 'GMT', origin = "1970-01-01")
  trim_xRight <- as.POSIXct(goop$trim_xRight, tz = 'GMT', origin = "1970-01-01")
  
  plot <- plot_ly(data = goop$trim_stations_df, type = 'scatter', mode = 'lines', x = ~Date_Time, y = ~Low_Range, key = ~(paste0(as.character(Date_Time),"-",as.character(station))), color = ~as.character(station), opacity = 0.9, source = "D") %>%
    layout(showlegend = FALSE, shapes = list(
      # left line
      list(type = "line", x0 = trim_xLeft, x1 = trim_xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # right line
      list(type = "line", x0 = trim_xRight, x1 = trim_xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    config(edits = list(shapePosition = TRUE))
  
  plot
  
})


observeEvent(event_data("plotly_relayout", source = "D"), {
  ed <- event_data("plotly_relayout", source = "D")
  shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
  if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
  barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
  if(is.na(barNum)){ return() } # just some secondary error checking to see if we got any NAs. This line should never be called
  row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # get shape number
  pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'GMT', origin = "1970-01-01")
  if(barNum == 0){
    goop$trim_xLeft <- 0
    goop$trim_xLeft <- pts[1]
  }else{
    goop$trim_xRight <- 0
    goop$trim_xRight <- pts[1]
  }
})


observeEvent(input$continue_button2, {
  updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel")
})

             
