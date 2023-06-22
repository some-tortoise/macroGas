library(shiny)
library(plotly)
library(tidyverse)
source(knitr::purl("updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  plotlyOutput("p")
)

server <- function(input, output, session) {
  
  goop <- reactiveValues()
  goop$combined_df <- combined_df
  
  observe({
    goop$curr_station_df <- combined_df[combined_df$station %in% 1, ]
  })
  
  observe({
    goop$curr_station_df$Date_Time <- goop$curr_station_df$Date_Time
  })
  
  observe({
    goop$calc_xValue <- goop$curr_station_df$Date_Time
    goop$calc_yValue <- goop$curr_station_df$Low_Range
  })
  
  observe({
    goop$calc_xLeft <- goop$calc_xValue[500]
    goop$calc_xRight <- goop$calc_xValue[2000]
  })
  
  output$p <- renderPlotly({
    req(goop$curr_station_df)
    req(goop$calc_xLeft)
    req(goop$calc_xRight)
    xVal <- goop$curr_station_df$Date_Time
    yVal <- goop$curr_station_df$Low_Range
    xLeft <- goop$calc_xLeft
    xRight <- goop$calc_xRight
    #print(xVal)
    #print(goop$curr_station_df$Date_Time)
    print(goop$curr_station_df$Date_Time[500])
    goop$curr_station_df$xfill <- ifelse(
      as.numeric(xVal) > as.numeric(xLeft) & as.numeric(xVal) < as.numeric(xRight),
      xVal,
      NA
    )
    
    xLeft <- as.POSIXct(xLeft, tz = 'GMT')
    xRight <- as.POSIXct(xRight, tz = 'GMT')
    
    plot_ly(goop$curr_station_df, x = ~as.POSIXct(Date_Time, tz = 'GMT'), y = ~Low_Range, 
            type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~as.POSIXct(goop$curr_station_df$xfill, tz = 'GMT'), y = ~Low_Range, fill = 'tozeroy') %>%
      layout(shapes = list(
        # left line
        list(type = "line", x0 = xLeft, x1 = xLeft,
             y0 = 0, y1 = 1, yref = "paper"),
        # right line
        list(type = "line", x0 = xRight, x1 = xRight,
             y0 = 0, y1 = 1, yref = "paper")
      )) %>%
      config(edits = list(shapePosition = TRUE))
  })
  
  observeEvent(event_data("plotly_relayout"), {
    ed <- event_data("plotly_relayout")
    shape_anchors <- ed[grepl("^shapes.*x0$", names(ed))]
    if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a shape
    barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
    if(is.na(barNum)){ return() } # just some secondary error checking to see if we got any NAs. This line should never be called
    row_index <- unique(readr::parse_number(names(shape_anchors)) + 1) # get shape number
    pts <- as.POSIXct(substring(shape_anchors,1,19), tz = 'GMT')
    
    if(barNum == 0){
      goop$calc_xLeft <- 0
      goop$calc_xLeft <- pts[1]
    }else{
      goop$calc_xRight <- 0
      goop$calc_xRight <- pts[1]
    }
  })
  
}

shinyApp(ui, server)
