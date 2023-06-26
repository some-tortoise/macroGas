color_mapping <- c("1" = "red", "2" = "orange", "3" = "#008000", "4" = "blue", "5" = "purple")



  output$orig_plot <- renderPlot({
    ggplot(goop$combined_df, aes(x = Date_Time, y = Full_Range, color = as.character(station))) +
      geom_line(size = 1.1) +
      theme_bw() +
      labs(
        x = "Date Time",
        y = "Full Range",
        color = "Station"
      ) +
      scale_color_manual(values = color_mapping)
  })
  
  observeEvent(input$station_reorder, {
    
    ordered_labels <- unlist(input[["rank_list"]])
    ordered_values <- c("1", "2", "3", "4", "5")
    ordered_values <- ordered_values[match(ordered_labels, c("Red", "Orange", "Green", "Blue", "Purple"))]
  
    curNum <- 0
    curVal <- 0
    
  for (i in 1:length(goop$combined_df$station)) {
    if(goop$combined_df[i, 'Station'] != curVal){
      curVal <- goop$combined_df[i, 'station']
      curNum <- curNum + 1
    }
    
    goop$combined_df[i, 'station'] <- ordered_values[curNum]
      
  }
    output$reorder_complete <- renderText("Reorder Complete!") 
    })


