library(shiny)
library(plotly)
library(tidyverse)
source(knitr::purl("updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

eggs <- combined_df[combined_df$station %in% 1,]
eggs$Date_Time <- as.numeric(eggs$Date_Time)
xValue <- eggs['Date_Time'][,1]
yValue <- eggs['Low_Range'][,1]
data <- data.frame(xValue,yValue)

ui <- fluidPage(
  plotlyOutput("p")
)

server <- function(input, output, session) {
  
  calcBars = reactiveValues(xLeft = xValue[500], xRight = xValue[2000])
  
  output$p <- renderPlotly({
    
    eggs$xfill = ifelse(xValue > calcBars$xLeft & xValue < calcBars$xRight, xValue, NA)
    
    plot_ly(eggs, x = ~Date_Time, y = ~Low_Range, 
            type = 'scatter', mode = 'lines') %>%
      add_trace(x = ~xfill, y = ~Low_Range, fill = 'tozeroy') %>%
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
    if(substring(names(ed)[1],1,6) != 'shapes'){ return() } # gets rid of NA error when not clicking a
    barNum <- as.numeric(substring(names(ed)[1],8,8)) # gets 0 for left bar and 1 for right bar
    row_index <- unique(readr::parse_number(names(shape_anchors)) + 1)
    pts <- as.numeric(shape_anchors)
    data$x[row_index] <- pts[1]

    if(barNum == 0){
      calcBars$xLeft <- NA
      calcBars$xLeft <- data$x[row_index]
    }else{
      calcBars$xRight <- NA
      calcBars$xRight <- data$x[row_index]
    }
  })
  
}

shinyApp(ui, server)
