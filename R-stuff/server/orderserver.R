library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
library(sortable)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))

order_data <- reactiveValues(df = combined_df)

color_mapping <- c("1" = "red", "2" = "orange", "3" = "green", "4" = "blue", "5" = "purple")

#orderserver <- function(input, output, session) {
  output$orig_plot <- renderPlot({
    ggplot(order_data$df, aes(x = Date_Time, y = Full_Range, color = station)) +
      geom_line() +
      scale_color_manual(values = color_mapping)
  })
  
  observeEvent(input$station_reorder, {
    ordered_labels <- unlist(input[["rank_list"]])
    ordered_values <- c("1", "2", "3", "4", "5")
    ordered_values <- ordered_values[match(ordered_labels, c("red", "orange", "green", "blue", "purple"))]
  
    curNum <- 0
    curVal <- 0
    
  for (i in 1:length(order_data$df$station)) {
    if(order_data$df[i, 'station'] != curVal){
      curVal <- order_data$df[i, 'station']
      curNum <- curNum + 1
    }
    
    order_data$df[i, 'station'] <- ordered_values[curNum]
      
  }
  print("Reorder Registered!")  
    })
#} 

