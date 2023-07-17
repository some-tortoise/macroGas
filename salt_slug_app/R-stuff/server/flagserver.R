observe({
  if(!is.null(goop$combined_df)){
    filteredData <- reactive({
      df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
    })
    
    output$station <- renderUI({
      num_station <- sort(unique(goop$combined_df$station)) 
      radioButtons('station', label = "Select station to graph", num_station)
    })
    
    output$variable_c <- renderUI({
      radioButtons("variable_choice",label = 'Select variable to graph',
                   choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C'))
    })
    
    output$main_plot <- renderUI({
      plotlyOutput("flag_plot")
    })
    
    output$flag_plot <- renderPlotly({
      plot_ly(data = filteredData(), type = 'scatter', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), 
              key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.8) |>
        layout(xaxis = list(title = "Date and Time"), 
               yaxis = list(title = if (input$variable_choice == "Low_Range") {"Low Range Conductivity"}
                            else if (input$variable_choice == "Full_Range") {"Full Range Conductivity"}
                            else if (input$variable_choice == "Temp_C") {"Temperature (C)"}
                            else {""}),
               dragmode = 'select') |>
        config(displaylogo = FALSE, modeBarButtonsToRemove = c("toImage", "sendDataToCloud", "pan2d", "lasso2d", "zoomIn2d", "zoomOut2d", "resetScale2d", "hoverClosestCartesian", "hoverCompareCartesian")) %>%
        event_register(event = "plotly_selected")
    })
  }
  else{
    filteredData <- reactive({
      df_plot <- NULL
    })
    
    output$station <- renderUI({
      HTML("<label>Select station to graph<br></br></label>")
    })
    
    output$variable_c <- renderUI({
      HTML("<label>Select variable to graph<br></br></label>")
    })
    
    output$start_datetime_input <- renderUI({
      textInput("start_datetime", "Enter start date and time (YYYY-MM-DD HH:MM:SS)", value = "")
    })
    
    output$end_datetime_input <- renderUI({
       textInput("end_datetime", "End date and time", value = "")
    })
    
    output$main_plot <- renderUI({})
  }
})


selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
  event.selected.data <- event_data(event = "plotly_selected")
  df_chosen <- df_plot[paste0(df_plot$Date_Time,'_',df_plot$station) %in% event.selected.data$key,]
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

upload_csv_file <- function(clean_df, name, folder_path){
  file <- paste('processed_',name, sep='')
  file <- drive_put(
    media = file,
    name = file,
    type = 'csv',
    path = as_id(folder_path))
  return('success')
}

turn_file_to_csv <- function(clean_df, name){
  write.csv(clean_df, paste('./processed_',name, sep=''), row.names=FALSE)
}

observeEvent(input$downloadFlaggedDataset, {
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
    "processed.csv"
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
  name <- 'processed.csv'
  turn_file_to_csv(goop$trimmed_slug, name)
  res = tryCatch(upload_csv_file(goop$trimmed_slug, name, input$drivePath), error = function(i) NA)
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
