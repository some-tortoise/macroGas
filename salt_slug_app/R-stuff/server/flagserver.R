library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))

output$station <- renderUI({
  num_station <- unique(goop$combined_df$station)
  radioButtons('station', label = "Select station to graph", num_station)
})

# Reactive expression for filtered data
filteredData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
})

output$start_datetime_input <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("start_datetime", "Enter start date and time (YYYY-MM-DD HH:MM:SS)", value = default_value)
})

output$end_datetime_input <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("end_datetime", "End date and time", value = default_value)
})

# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  # unique_station = unique(goop$combined_df$station)
  # rainbow_color = rainbow(length(unique_station))
  # color_mapping <- c()
  # for(i in seq(unique_station)){
  #   color_mapping[as.character(i)] <- rainbow_color[i]
  # }
  plot_ly(data = filteredData(), type = 'scatter', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), 
              key = ~(paste0(as.character(id),"_",as.character(station))), color = ~as.character(station), opacity = 0.5) |>
    layout(dragmode = 'select') |>
    event_register(event = "plotly_selected")
})

selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
  event.selected.data <- event_data(event = "plotly_selected")
  df_chosen <- df_plot[paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key,]
  return(df_chosen)
}) 

output$selected_data_table <- renderDT({
  datatable(selectedData(), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
})

observeEvent(input$flag_btn, {
  flag_name <- paste0(input$variable_choice, "_Flag")
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)), flag_name] <- input$flag_type  # Set the flag
})

#
# EXPORT STUFF
#