#
# PLOT 
#


# Creates radio buttons and the plot based on new filteredData reactive that's set to station choice
observeEvent(goop$combined_df, {
  View(goop$combined_df)
  melted_comb_df <- melt(goop$combined_df,
                         id.vars = c("Date_Time", "station"),
                         measure.vars = c("Low_Range",
                                          "Full_Range",
                                          "Temp_C")) |>
    rename(Variable = variable,
           Station = station,
           Value = value) %>% mutate(Flag = "NA", id = row.names(.))
  goop$melted_combined_df <- melted_comb_df
  View(goop$melted_combined_df)
})

observe({
  if(!is.null(goop$combined_df)){ 
    
    # New reactive expression that filters data to user's station choice
    filteredData <- reactive({
      print(input$station)
      print(unique(goop$melted_combined_df$Station))
      df_plot <- goop$melted_combined_df[goop$melted_combined_df$Station == input$station,]
      #df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
    })
    
    # RenderUI to create radio buttons for each station that is present
    output$station <- renderUI({
      num_station <- sort(unique(goop$combined_df$station)) # use sort to make sure in numerical order
      radioButtons('station', label = "Select station to graph", num_station)
    })
    
    # RenderUI to create radio buttons for variables Low Range, Full Range or Temp
    output$variable_c <- renderUI({
      radioButtons("variable_choice",label = 'Select variable to graph',
                   choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C'))
    })
    
    # RenderUI to create the plot container
    output$main_plot <- renderUI({
      plotlyOutput("flag_plot")
    })
    
    # Plotly 
    output$flag_plot <- renderPlotly({
      # Color mapping: bad = red, interesting = orange, questionable = pink, NA = blue
      color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#601A3E", "NA" = "#9EC1CF")
      
      # Define x values (date_time), y values (value), and potential flags
      plotX <- filteredData()[filteredData()$Variable == input$variable_choice, 'Date_Time']
      plotY <- filteredData()[filteredData()$Variable == input$variable_choice, 'Value']
      plotFlag <- filteredData()[filteredData()$Variable == input$variable_choice, 'Flag']
      # Defining variables/formatting
      plot_ly(data = filteredData(), 
              type = 'scatter', 
              mode = 'markers', 
              x = plotX, 
              y = plotY,
              #y = as.formula(paste0('~', input$variable_choice)), 
              key = ~(paste0(as.character(plotX),"_",as.character(input$station))), 
              color = ~as.character(plotFlag), 
              colors = color_mapping, 
              opacity = 0.8) |>
        
        layout(xaxis = list(title = "Date and Time"), 
               yaxis = list(title = if (input$variable_choice == "Low_Range") {"Low Range Conductivity"}
                            else if (input$variable_choice == "Full_Range") {"Full Range Conductivity"}
                            else if (input$variable_choice == "Temp_C") {"Temperature (C)"}
                            else {""}),
               dragmode = 'select') |>
        
        # Remove unneccessary plotly buttons
        config(displaylogo = FALSE, modeBarButtonsToRemove = c("sendDataToCloud", "pan2d", "lasso2d", "zoomIn2d", "zoomOut2d", "resetScale2d", "hoverClosestCartesian", "hoverCompareCartesian")) %>%
        
        # Register an event for when points are selected -- for future flagging
        event_register(event = "plotly_selected")
    })
  }
  else{ # If combined_df is NULL, plot will be empty
    filteredData <- reactive({
      df_plot <- NULL
    })
    
    output$station <- renderUI({
      HTML("<label>Select station to graph<br></br></label>")
    })
    
    output$variable_c <- renderUI({
      HTML("<label>Select variable to graph<br></br></label>")
    })
    
    output$main_plot <- renderUI({})
  }
})

#
# SELECTED VALUES AND FLAGGING
#

# Reactive value that stores user selected points on the plotly and returns df_chosen
selectedData <- reactive({
  df_plot <- goop$melted_combined_df[goop$melted_combined_df$Station %in% input$station, ]
  event.selected.data <- event_data(event = "plotly_selected")
  df_chosen <- df_plot[paste0(df_plot$Date_Time,'_',df_plot$Station) %in% event.selected.data$key,]
  df_chosen <- df_chosen[df_chosen$Variable == input$variable_choice,]
  return(df_chosen)
})

# Adds the type of flag to new flag column based on user selection
observeEvent(input$flag_btn, {
  flag_name <- paste0(input$variable_choice, "_Flag")   

  # Assigns the flag from input$flag_type to where the id and station match from selectedData()
  goop$melted_combined_df[((goop$melted_combined_df$id %in% selectedData()$id) & (goop$melted_combined_df$Station %in% selectedData()$Station)), "Flag"] <- input$flag_type  
 
   #goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)), flag_name] <- input$flag_type  # Set the flag
})

#
# EXPORT 
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
    write.csv(goop$melted_combined_df, file, row.names = FALSE)
  }
)

observeEvent(input$upload_to_gdrive, {
  showModal(modalDialog(
    textInput('drivePath', 'Please enter the path of the folder in your googledrive:'),
    actionButton('flag_path_ok', 'OK')
  ))
})

