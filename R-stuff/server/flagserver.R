library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))
  
selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]  # Subset the combined dataframe based on selected station
  event.click.data <- event_data(event = "plotly_click", source = "imgLink")  # Get the clicked data from a plotly plot
  event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")  # Get the selected data from a plotly plot
  df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                          (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]  # Filter df_plot based on clicked and selected keys
  return(df_chosen)  # Return the filtered data
})
  
  
output$main_plot = renderPlotly({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station,]  # Subset the combined dataframe based on selected station
  color_mapping <- c("1" = "red", "2" = "orange", "3" = "#008000", "4" = "blue", "5" = "purple")  # Define a color mapping
  
  # Get the minimum and maximum values of Date_Time vector
  if(length(df_plot$Date_Time) > 0){
    min_date <- min(df_plot$Date_Time)  # Calculate the minimum value of Date_Time
    max_date <- max(df_plot$Date_Time)  # Calculate the maximum value of Date_Time
  }else{
    min_date <- Sys.Date()  # Set minimum date as current system date
    max_date <- Sys.Date()  # Set maximum date as current system date
  }
  
  plot_ly(data = df_plot, type = 'scatter', mode = 'markers', x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~(paste0(id,"_",station)), color = ~as.character(station), colors = ~color_mapping, opacity = 0.5, source = "imgLink") %>%
    layout(xaxis = list(
      range = c(min_date, max_date),  # Set the desired range
      type = "date"  # Specify the x-axis type as date
    ), dragmode = 'select') |>
    config(modeBarButtonsToRemove = list( "pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>  # Remove specific buttons from the plot
    layout(plot_bgcolor='white', 
           xaxis = list(title = 'Date Time'))  # Set the plot background color and x-axis title
})
  
output$selected_data_table <- renderDT({
  datatable(selectedData(), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)  # Render a datatable with the selected data
})
  
observeEvent(input$flag_btn,{
  flag_name = paste0(input$variable_choice, "_Flag")  # Create a flag name based on the selected variable
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)),flag_name] <- input$flag_type  # Set the flag
  selectedData <- reactive({
    goop$combined_df })
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