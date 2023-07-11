
# selectedData <- reactive({
#   df_plot <- goop$combined_df[goop$combined_df$Station %in% input$Station,]
#   event.click.data <- event_data(event = "plotly_click", source = "imgLink")
#   event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
#   df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$Station) %in% event.click.data$key) | 
#                           (paste0(df_plot$id,'_',df_plot$Station) %in% event.selected.data$key)),]
#   df_chosen <- df_chosen[df_chosen$Variable == input$variable_choice,]
#   return(df_chosen)
# }) 
# 
# output$variable_c <- renderUI({
#   radioButtons("variable_choice",label = helpText('Select variable to graph'),
#                choices = unique(goop$combined_df$Variable))
# })
# 
# output$station <- renderUI({
# num_station <- unique(goop$combined_df$Station)
# radioButtons('Station', label = '', choices = setNames(num_station, num_station))
# })

# Reactive expression for filtered data
filteredData <- reactive({
  df_plot <- goop$combined_df
  selected_dates_qaqc <- input$qaqcDateRange
  #subset(df_plot, Date_Time >= selected_dates_qaqc[1] & Date_Time <= selected_dates_qaqc[2])
})
# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  plot_df = filteredData() %>% filter(Variable == input$variable_choice)
  plot_ly(data = plot_df, type = 'scatter', mode = 'markers', 
              x = ~Date_Time, y = ~Value, key = ~(paste0(as.character(id),"_",as.character(Station))), color = ~as.character(Station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = input$variable_choice))
})

# output$selected_data_table <- renderDT({
#   datatable(selectedData() %>% select(-c(id)), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
# })

observeEvent(input$flag_btn, {
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station)), "Flag"] <- input$flag_type  # Set the flag
})

#reset all flags
# observeEvent(input$Reset,{
#   showModal(modalDialog(
#     h4("Are you sure you want to reset all the flags?"),
#     easyClose = FALSE,
#     footer = tagList(
#       actionButton("reset_Yes", "Yes"),
#       modalButton("No")
#     )
#   ))
# })
# 
# observeEvent(input$reset_Yes,{
#   goop$combined_df$Flag = "good"
#   removeModal()
# })

output$varContainers <- renderUI({
  vars <- unique(goop$combined_df$Variable)
  LL <- vector("list",length(vars))       
  for(i in vars){
    LL[[i]] <- list(varContainerUI(id = i, var = i))
  }      
  return(LL)  
})

observe({
  lapply(unique(goop$combined_df$Variable), function(i) {
    varContainerServer(id = i, variable = i, goop = goop)
  })
})

# Download Clean Data in Longer Format
# output$download_longer <- downloadHandler(
#   filename = function() {
#     "processed_data.csv"
#   },
#   content = function(file) {
#   
# 
#     write.csv(goop$combined_df, file, row.names = FALSE)
#   }
# )
