xValue <- 1:50
yValue <- abs(cumsum(rnorm(50)))
goop$data <- data.frame(xValue,yValue)

calcBars <- reactiveValues(xLeft = 10, xRight = 30)

output$dischargecalcplot <- renderPlotly({
  goop$data$xfill = ifelse(xValue > calcBars$xLeft & xValue < calcBars$xRight, xValue, NA)
  
  plot_ly(goop$data, x = ~xValue, y = ~yValue, 
          type = 'scatter', mode = 'lines') %>%
    add_trace(x = ~xfill, y = ~yValue, fill = 'tozeroy') %>%
    layout(shapes = list(
      # left line
      list(type = "line", x0 = calcBars$xLeft, x1 = calcBars$xLeft,
           y0 = 0, y1 = 1, yref = "paper"),
      # right line
      list(type = "line", x0 = calcBars$xRight, x1 = calcBars$xRight,
           y0 = 0, y1 = 1, yref = "paper")
    )) %>%
    config(edits = list(shapePosition = TRUE))
})


observeEvent(event_data("plotly_relayout"), {
  ed <- event_data("plotly_relayout")
  shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
  print(substring(names(ed)[1],1,6))
  if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
  barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
  if(is.na(barNum)){ return() }
  row_index <- unique(readr::parse_number(names(shape_anchors)) + 1)
  pts <- as.numeric(shape_anchors)
  goop$data$x[row_index] <- pts[1]
  
  
  if(barNum == 0){
    calcBars$xLeft <- NA
    calcBars$xLeft <- goop$data$x[row_index]
  }else{
    calcBars$xRight <- NA
    calcBars$xRight <- goop$data$x[row_index]
  }
})