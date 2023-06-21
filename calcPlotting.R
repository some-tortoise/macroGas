library(shiny)
library(plotly)
library(tidyverse)

xValue <- 1:50
yValue <- abs(cumsum(rnorm(50)))
data <- data.frame(xValue,yValue)

ui <- fluidPage(
  plotlyOutput("p")
)

server <- function(input, output, session) {
  
  calcBars = reactiveValues(xLeft = 10, xRight = 30)
  
  output$p <- renderPlotly({
    
    data$xfill = ifelse(xValue > calcBars$xLeft & xValue < calcBars$xRight, xValue, NA)
    
    plot_ly(data, x = ~xValue, y = ~yValue, 
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
