

selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$Station %in% input$Station,]
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
  df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$Station) %in% event.click.data$key) | 
                          (paste0(df_plot$id,'_',df_plot$Station) %in% event.selected.data$key)),]
  df_chosen <- df_chosen[df_chosen$Variable == input$variable_choice,]
  return(df_chosen)
}) 

output$variable_c <- renderUI({
  radioButtons("variable_choice",label = helpText('Select variable to graph'),
               choices = unique(goop$combined_df$Variable))
})

output$station <- renderUI({
num_station <- unique(goop$combined_df$Station)
radioButtons('Station', label = '', choices = setNames(num_station, num_station))
})

# Reactive expression for filtered data
filteredData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$Station %in% input$Station, ]
})

output$start_datetime_input <- renderUI({
  if (!is.null(goop$combined_df)) {
    default_value <- as.character(min(goop$combined_df$Date_Time))
  } else {
    default_value <- ""
  }
  textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
})

output$end_datetime_input <- renderUI({
  if (!is.null(goop$combined_df)) {
    default_value <- as.character(max(goop$combined_df$Date_Time))
  } else {
    default_value <- ""
  }
  textInput("end_datetime", "End Date and Time", value = default_value)
})

# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  start_time = tryCatch(as.POSIXct(input$start_datetime, "UTC"), 
                        error = function(e) min(goop$combined_df$Date_Time))
  end_time = tryCatch(as.POSIXct(input$end_datetime, "UTC"), 
                      error = function(e) max(goop$combined_df$Date_Time))
  plot_df = filteredData() %>% filter(Variable == input$variable_choice,
                                      Date_Time >= start_time,
                                      Date_Time <= end_time)
  print(end_time)
  plot_ly(data = plot_df, type = 'scatter', mode = 'markers', 
              x = ~Date_Time, y = ~Value, key = ~(paste0(as.character(id),"_",as.character(Station))), color = ~as.character(Station), opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      range = c(start_time - hours(1), end_time + hours(1)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = input$variable_choice))
})

output$selected_data_table <- renderDT({
  datatable(selectedData() %>% select(-c(id)), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
})

observeEvent(input$flag_btn, {
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station)), "Flag"] <- input$flag_type  # Set the flag
})

#reset all flags
observeEvent(input$Reset,{
  showModal(modalDialog(
    h4("Are you sure you want to reset all the flags?"),
    easyClose = FALSE,
    footer = tagList(
      actionButton("reset_Yes", "Yes"),
      modalButton("No")
    )
  ))
})

observeEvent(input$reset_Yes,{
  goop$combined_df$Flag = "good"
  removeModal()
})

output$varContainers <- renderUI({
  LL <- vector("list",10)       
  for(i in unique(goop$combined_df$Variable)){
    LL[[i]] <- list(varContainerUI(id = i, var = i))
  }      
  return(LL)  
})

observe({
  for(i in unique(goop$combined_df$Variable)){
    varContainerServer(i, goop = goop)
  }
})

# Download Clean Data in Longer Format
output$download_longer <- downloadHandler(
  filename = function() {
    "processed_data.csv"
  },
  content = function(file) {
  

    write.csv(goop$combined_df, file, row.names = FALSE)
  }
)
