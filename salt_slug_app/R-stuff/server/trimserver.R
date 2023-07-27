# Creates goop$trim_stations_df from those picked in station_picker
observe({
  goop$trim_stations_df <- goop$combined_df
}) 

# Creates goop$trim_xValue and goop$trim_yValue from DateTime and Low_Range (for x and y values)
observe({
  goop$trim_xValue <- goop$trim_stations_df$Date_Time
  goop$trim_yValue <- goop$trim_stations_df$Low_Range
}) 

# Values to store location of vertical bars in goop
observe({
    goop$trim_xLeft <- goop$trim_xValue[1] # furthest left value
    goop$trim_xRight <- goop$trim_xValue[length(goop$trim_xValue) - 1] # furthest right value
})

# Plotly of all the uploaded stations to trim
output$trim_plot <- renderPlotly({
  # Requirement
  req(goop$trim_xLeft)
  
  # Save reactive values of the trim bar locations to trim_xLeft and trim_xRight as as.POSIXct date/time values
  trim_xLeft <- as.POSIXct(goop$trim_xLeft, tz = 'EST', origin = "1970-01-01")
  trim_xRight <- as.POSIXct(goop$trim_xRight, tz = 'EST', origin = "1970-01-01")
  
  # Plot of entire combined_df (all stations) the user put into the upload page
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
      showlegend = TRUE, shapes = list(
      # Left vertical line
      list(type = "line", x0 = trim_xLeft, x1 = trim_xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # Right vertical line
      list(type = "line", x0 = trim_xRight, x1 = trim_xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    
    # Gets rid of Plotly modebar and allows the vertical lines to be editable by user
    config(displaylogo = FALSE, modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian", "zoom", "zoomIn", "zoomOut", "select"), edits = list(shapePosition = TRUE))
  
  plot
  
})

# Filter combined_df into trimmed_combined_df based on Date_Time values set by the trim bars 
observe({
  goop$trimmed_combined_df <- goop$combined_df[goop$combined_df$Date_Time > goop$trim_xLeft & goop$combined_df$Date_Time < goop$trim_xRight, ]
  
})

# Updating the vertical bar positions based on the user interaction
observeEvent(event_data("plotly_relayout", source = "D"), { 
  ed <- event_data("plotly_relayout", source = "D") # Retrieves  event data when the user interacts with the Plotly ('D' is plot)
  shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))] # Extracts shape anchors from event data
  
  if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # Checks if the event data contains shapes to get rid of NA error when user isn't clicking a shape
  barNum <- as.numeric(substring(names(ed)[1],8,8)) # Get the bar number (0 for left bar and 1 for right bar) from the first shape name
  if(is.na(barNum)){ return() } # Secondary error checking to see if we got any NAs. This line should never be called
  
  row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # Get the index of the row (shape number) from the shape anchors
  
  pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'EST', origin = "1970-01-01") # Convert shape anchors to date-time format 
  
  # Updates the left or right bar position based on the user interaction
  if(barNum == 0){
    goop$trim_xLeft <- 0
    goop$trim_xLeft <- pts[1]
  }else{
    goop$trim_xRight <- 0
    goop$trim_xRight <- pts[1]
  }
})

# Trims the data when user selects the continue button 
observeEvent(input$trimContinue, {
  
  # Trime goop$combined_df between goop$trim_xLeft and goop$trim_xRight here
  temp <- subset(goop$combined_df, Date_Time > goop$trim_xLeft)
  temp <- subset(temp, Date_Time < goop$trim_xRight)
  
  if(length(temp) > 1){ #If data remains update both goop$combined_df and goop$melted_combined_df with trimmed data
    goop$combined_df <- temp
    updateTabsetPanel(session, inputId = "navbar", selected = "flagpanel") # Move user to QAQC page
    
  }else{ 
    print('Make sure some data remains in trim') 
  }
  # goop$combined_df <- subset(goop$combined_df, Date_Time > goop$trim_xLeft)
  # goop$combined_df <- subset(goop$combined_df, Date_Time < goop$trim_xRight)
  
})