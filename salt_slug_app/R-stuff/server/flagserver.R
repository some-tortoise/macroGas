library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))

selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
  df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                          (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]
  return(df_chosen)
}) 

output$station <- renderUI({
  num_station <- unique(combined_df$station)
  radioButtons('station', label = '', num_station)
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
  textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = default_value)
})

output$end_datetime_input <- renderUI({
  if (nrow(goop$combined_df) > 0) {
    default_value <- as.character(goop$combined_df$Date_Time[1])
  } else {
    default_value <- ""
  }
  textInput("end_datetime", "End Date and Time", value = default_value)
})

# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  unique_station = unique(combined_df$station)
  rainbow_color = rainbow(length(unique_station))
  color_mapping <- c()
  for(i in seq(unique_station)){
    color_mapping[as.character(i)] <- rainbow_color[i]
  }
  p = plot_ly(data = filteredData(), type = 'scatter', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), key = ~(paste0(id,"_",station)), color = ~as.character(station), colors = ~color_mapping, opacity = 0.5, source = "imgLink") |>
    layout(xaxis = list(
      range = c(as.POSIXct(input$start_datetime), as.POSIXct(input$end_datetime)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
  p = event_register(p, 'plotly_relayout')
  p
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

observeEvent(input$download, {
  showModal(modalDialog(
    title = 'How do you want to download your dataset?',
    downloadButton('downloadBtn', 'Download'),
    actionButton('upload_to_gdrive', 'Upload to Google Drive'),
    easyClose = FALSE,
    footer = tagList(
      modalButton("Close")
    )
  ))
})

output$downloadBtn <- downloadHandler(
  filename = function() {
    # Set the filename of the downloaded file
    "flagged_data.csv"
  },
  content = function(file) {
    # Generate the content of the file
    write.csv(goop$combined_df, file, row.names = FALSE)
  }
)

observeEvent(input$upload_to_gdrive, {
  showModal(modalDialog(
    textInput('drivePath', 'Please enter the path of the folder in your googledrive:'),
    actionButton('path_ok', 'OK')
  ))
})

observeEvent(input$path_ok,{
  name <- 'flagged_data.csv'
  turn_file_to_csv(goop$combined_df, name)
  res = tryCatch(upload_csv_file(goop$combined_df, name, input$drivePath), error = function(i) NA)
  if(is.na(res)){
    showModal(modalDialog(
      h3('The path you entered is invalid!'),
      easyClose = FALSE,
      footer = tagList(
        modalButton('Back')
      )
    ))      
  }
  else{
    if(paste0('processed_', name) %in% (drive_ls(input$drivePath)[['name']])){
      showModal(modalDialog(
        h3('File has been uploaded successfully!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
    else{
      showModal(modalDialog(
        h3('File upload failed!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
  }
}
)