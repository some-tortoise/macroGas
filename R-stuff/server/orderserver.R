library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
library(sortable)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))


orderserver <- function(input, output, session) {
  
  observeEvent(input$station_reorder, {
    ordered_labels <- unlist(input[["rank_list_swap"]])
    ordered_values <- c("1", "2", "3", "4", "5")
    ordered_values <- ordered_values[match(ordered_labels, c("Station A", "Station B", "Station C", "Station D", "Station E"))]
    print(ordered_values)
  
    curNum <- 0
    curVal <- 0
    #(length(combined_df$station))
  for (i in 1:length(combined_df$station)) {
    if(combined_df[i, 'station'] != curVal){
      curVal <- combined_df[i, 'station']
      curNum <- curNum + 1
      #print(ordered_values[curNum])
    }
    
    combined_df[i, 'station'] <- ordered_values[curNum]
      
      }
  output$ordered_plot <- renderPlot({
      ggplot(combined_df, aes(x = Date_Time, y = Full_Range)) +
              geom_line(color = station)
             })
    })
} 

