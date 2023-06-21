

color_mapping <- c("1" = "red", "2" = "blue", "3" = "green", "4" = "purple", "5" = "black")

output$orig_plot <- renderPlot({
  ggplot(combined_df, aes(x = Date_Time, y = Full_Range, color = station)) +
    geom_line() +
    scale_color_manual(values = color_mapping)
})

observeEvent(input$station_reorder, {
  ordered_labels <- unlist(input[["rank_list"]])
  ordered_values <- c("1", "2", "3", "4", "5")
  ordered_values <- ordered_values[match(ordered_labels, c("Station 1", "Station 2", "Station 3", "Station 4", "Station 5"))]
  print(ordered_values)
  curNum <- 0
  curVal <- 0
  
  for (i in 1:length(combined_df$station)) {
    if(combined_df[i, 'station'] != curVal){
      curVal <- combined_df[i, 'station']
      curNum <- curNum + 1
      print(curVal)
    }
    combined_df[i, 'station'] <- ordered_values[6 - curNum]
  }
  
  output$ordered_plot <- renderPlot({
    print('goobers')
    ggplot(combined_df, aes(x = Date_Time, y = Full_Range, color = station)) +
      geom_line() +
      scale_color_manual(values = color_mapping)
  })

})
