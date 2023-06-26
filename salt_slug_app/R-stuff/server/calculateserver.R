observeEvent(goop$combined_df, {
  st <- c(0)
  a <- data.frame(st)
  colNames <- list('Station 1')
  for(i in 1:(length(unique(goop$combined_df$station)) - 1)){
    st <- c(0)
    a <- cbind(a, st)
    colNames <- append(colNames, paste0('Station ', i + 1))
  }
  
  row.names(a) <- 'Discharge'
  colnames(a) <- colNames
  goop$dichargeDF <- a
  #View(goop$dichargeDF)
})

observe({
  goop$calc_curr_station_df <- combined_df[combined_df$station %in% input$calc_station_picker, ]
}) #filters to the subset of rows that has the correct station the user inputs, then stores in goop$calc_curr_station_df

observe({
  goop$calc_curr_station_df$Date_Time <- goop$calc_curr_station_df$Date_Time
})

observe({
  goop$calc_xValue <- goop$calc_curr_station_df$Date_Time
  goop$calc_yValue <- goop$calc_curr_station_df$Low_Range
}) #assigns date/time to the x-axis, conductivity to the y-axis 

observe({
  goop$calc_xLeft <- goop$calc_xValue[500]
  goop$calc_xRight <- goop$calc_xValue[2000]
  goop$calc_xOne <- as.numeric(goop$calc_xValue[1])
})

observe({
  goop$trimmed_slug <- goop$calc_curr_station_df[(as.numeric(goop$calc_xValue) >= as.numeric(goop$calc_xLeft)) & (as.numeric(goop$calc_xValue) <= as.numeric(goop$calc_xRight)), ]
})

observeEvent(input$calc_station_picker, {
  goop$calc_curr_station_df <- combined_df[combined_df$station %in% input$calc_station_picker, ]
})

output$start_time <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
}) #start time renderUI

output$end_time <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("end_datetime", "End Date and Time", value = default_value)
}) #end time renderUI


observe({
  goop$calc_discharge_table <- NULL
})

output$dischargeOutput <- renderText({
  station_slug <- goop$trimmed_slug
  
  station_slug <- station_slug %>%
    mutate(NaCl_Conc = NA) %>%
    relocate(NaCl_Conc, .after = Low_Range)
  station_slug <- station_slug %>%
    mutate(Area = NA) %>%
    relocate(Area, .after = NaCl_Conc)
  
  background_cond <- as.numeric(input$background) 
  station_slug <- station_slug %>%
    mutate(NaCl_Conc = (Low_Range - background_cond) * 0.00047) %>%
    mutate(Area = NaCl_Conc * 5)
  
  Area <- sum(station_slug$Area)
  Mass_NaCl <- input$salt_mass
  Discharge <- Mass_NaCl/Area
  goop$dichargeDF[[as.numeric(input$calc_station_picker)]] <- Discharge
  return(paste0('Discharge: ',Discharge))
}) #the math.R stuff that prints a final discharge value

observeEvent(event_data("plotly_relayout"), {
  ed <- event_data("plotly_relayout")
  shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
  if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
  barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
  if(is.na(barNum)){ return() } # just some secondary error checking to see if we got any NAs. This line should never be called
  row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # get shape number
  pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'GMT', origin = "1970-01-01")
  
  if(barNum == 0){
    goop$calc_xLeft <- 0
    goop$calc_xLeft <- pts[1]
  }else{
    goop$calc_xRight <- 0
    goop$calc_xRight <- pts[1]
  }
})

output$dischargecalcplot <- renderPlotly({
  
  req(goop$calc_curr_station_df)
  req(goop$calc_xLeft)
  req(goop$calc_xRight)
  xVal <- goop$calc_curr_station_df$Date_Time
  yVal <- goop$calc_curr_station_df$Low_Range
  xLeft <- goop$calc_xLeft
  xRight <- goop$calc_xRight
  
  goop$calc_curr_station_df$xfill <- ifelse(
    as.numeric(xVal) > as.numeric(xLeft) & as.numeric(xVal) < as.numeric(xRight),
    xVal,
    NA
  )
  
  xLeft <- as.POSIXct(xLeft, tz = 'GMT', origin = "1970-01-01")
  xRight <- as.POSIXct(xRight, tz = 'GMT', origin = "1970-01-01")
  
  p <- plot_ly(goop$calc_curr_station_df, x = ~Date_Time, y = ~Low_Range, 
          type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~as.POSIXct(goop$calc_curr_station_df$xfill, tz = 'GMT', origin = "1970-01-01"), y = ~Low_Range, fill = 'tozeroy') %>%
    layout(shapes = list(
      # left line
      list(type = "line", x0 = xLeft, x1 = xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # right line
      list(type = "line", x0 = xRight, x1 = xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    config(edits = list(shapePosition = TRUE))
  p <- event_register(p, 'plotly_relayout')
  p
  
})

output$dischargetable <- renderDT({
 datatable(goop$dichargeDF) 
})
