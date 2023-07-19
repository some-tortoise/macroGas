observe({
  goop$trim_stations_df <- goop$combined_df
}) #creates goop$trim_stations_df from those picked in station_picker

observe({
  goop$trim_xValue <- goop$trim_stations_df$Date_Time
  goop$trim_yValue <- goop$trim_stations_df$Low_Range
}) #creates goop$trim_xValue and goop$trim_yValue from DateTime and Low_Range

observe({
    goop$trim_xLeft <- goop$trim_xValue[1] #sets vertical bar to farthest left
    goop$trim_xRight <- goop$trim_xValue[length(goop$trim_xValue) - 1] #sets vertical bar to farthest right
})

output$trim_plot <- renderPlotly({
  req(goop$trim_xLeft)
  trim_xLeft <- as.POSIXct(goop$trim_xLeft, tz = 'GMT', origin = "1970-01-01")
  trim_xRight <- as.POSIXct(goop$trim_xRight, tz = 'GMT', origin = "1970-01-01")
  
  plot <- plot_ly(data = goop$combined_df, 
                  type = 'scatter', 
                  mode = 'lines', 
                  x = ~Date_Time, 
                  y = ~Low_Range, 
                  key = ~(paste0(as.character(Date_Time),"-",as.character(station))), 
                  color = ~as.character(station), 
                  opacity = 0.9, 
                  source = "D") %>%
    layout(xaxis = list(title = "Date and Time"), 
           yaxis = list(title = "Low Range Conductivity"),
      showlegend = FALSE, shapes = list(
      # left line
      list(type = "line", x0 = trim_xLeft, x1 = trim_xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # right line
      list(type = "line", x0 = trim_xRight, x1 = trim_xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    config(displayModeBar = FALSE, edits = list(shapePosition = TRUE))
  
  plot
  
})

observe({
  goop$trimmed_combined_df <- goop$combined_df[goop$combined_df$Date_Time > goop$trim_xLeft & goop$combined_df$Date_Time < goop$trim_xRight, ]
  
})

output$trimmed_plot <- renderPlotly({
  plotKey <- paste0(as.character(goop$trimmed_combined_dfDate_Time),"-",as.character(station))
  plot <- plot_ly(data = goop$trimmed_combined_df, 
          type = 'scatter', 
          mode = 'lines', 
          x = ~Date_Time, 
          y = ~Low_Range, 
          key = ~(plotKey), 
          color = ~as.character(station), 
          opacity = 0.9)
  return(plot)
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


observeEvent(input$trimContinue, {
  #trim goop$combined_df between goop$trim_xLeft and goop$trim_xRight here
  temp <- subset(goop$combined_df, Date_Time > goop$trim_xLeft)
  temp <- subset(temp, Date_Time < goop$trim_xRight)
  temp_melted <- subset(goop$melted_combined_df, Date_Time > goop$trim_xLeft)
  temp_melted <- subset(temp_melted, Date_Time < goop$trim_xRight)
  if(length(temp) > 1){
    goop$combined_df <- temp
    goop$melted_combined_df <- temp_melted
    updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel")
  }else{
    print('make sure some data remains in trim')
  }
  # goop$combined_df <- subset(goop$combined_df, Date_Time > goop$trim_xLeft)
  # goop$combined_df <- subset(goop$combined_df, Date_Time < goop$trim_xRight)
  
})

             
