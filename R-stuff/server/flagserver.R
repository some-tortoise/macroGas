library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))

df <- reactive(data.frame(
  Date_Time = seq(from = as.POSIXct("2023-01-01 00:00:00"), to = as.POSIXct("2023-01-10 23:59:59"), by = "5 secs"),
  Value = rnorm(nrow(goop$combined_df))
))

selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
  df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                          (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]
  return(df_chosen)
}) 

# Reactive expression for filtered data based on start and end date and time
filteredData <- reactive({
  start_datetime <- as.POSIXct(input$start_datetime)
  end_datetime <- as.POSIXct(input$end_datetime)
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
  df_plot[df_plot$Date_Time >= start_datetime & df_plot$Date_Time <= end_datetime, ]
})

# Render the Plotly graph with updated start and end date and time
output$main_plot <- renderPlotly({
  plot_ly(data = filteredData(), type = 'scatter', mode = 'markers', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), key = ~(paste0(id,"_",station)), color = ~as.character(station), colors = ~color_mapping, opacity = 0.5, source = "imgLink") %>%
    layout(xaxis = list(
      range = c(as.POSIXct(input$start_datetime), as.POSIXct(input$end_datetime)),  # Set the desired range from start date and time to end date and time
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
    layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'))
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