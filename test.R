library(shiny)
library(ggplot2)
library(hrbrthemes)

ui <- fluidPage(
  plotOutput('plot')
)


server <- function(input, output) {
  output$plot <- renderPlot({
    leftBound <- 2
    rightBound <- 6
    
    xValue <- 1:10
    yValue <- abs(cumsum(rnorm(10)))
    data <- data.frame(xValue,yValue,xfill = ifelse(xValue > leftBound & xValue < rightBound, xValue, NA))
    
    # Plot
    ggplot(data, aes(x=xValue, y=yValue)) +
      geom_area(aes(x=xfill), fill="#69b3a2", alpha=0.4) +
      geom_line(color="#69b3a2", size=2)
  })
}

shinyApp(ui = ui, server = server)
