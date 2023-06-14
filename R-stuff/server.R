library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

server <- function(input, output, session){
  
  #
  # LOAD IN METHOD CHOICE
  #
  {
    #hide("manual_container")
    #hide("viz_container_div")
    
    observeEvent(input$manual_choice, {
      show("manual_container")
      show("viz_container_div")
    })
    
    observeEvent(input$gdrive_choice, {
      #alert('This option is currently unavailable.')
      show("viz_container_div")
    })
  }
  
  #
  # UPLOAD STUFF
  #
  {
    output$template <- renderUI({
      HTML("<h4><b>The file you upload should have the following features:</b></h4> 
           <li>A csv file</li>
           <li>With columns: Date Time, Conductivity, Temparature, Station(optional)</li>")
    })
    
    output$example <- renderUI({
      HTML(paste0("<li>",actionLink("template", label = "Example of data format"), "</li>"))
    })
    
    observeEvent(input$template,{
      showModal(modalDialog(
        title = "Example Format",
        tableOutput("eg_table"),
        footer = tagList(
          modalButton('Back')
        )
      ))
    })
    
    # need to fill this
    output$eg_table <- renderTable(
      data.frame()
    )
    
    uploaded_data <- reactiveValues(csv_names = NULL, 
                                    data = NULL,
                                    index = 1,
                                    station_names = NULL,
                                    combined_df = NULL)
    
    observeEvent(input$csvs, {
      in_file <- NULL
      success <- FALSE
      tryCatch({
        in_file <- read.csv(input$csvs$datapath,
                            header = TRUE,
                            sep = ",")
      }, error = function(e){
        in_file <- NULL
      })
      
      if(!is.null(in_file)){
        names <- colnames(in_file)
        if("station" %in% names){
          if(identical(sort(names), sort(c("Date_Time", "Low_Range", "Full_Range", "Temp_C", "station"))))
            success <- TRUE
        }
        else{
          if(identical(sort(names), sort(c("Date_Time", "Low_Range", "Full_Range", "Temp_C"))))
            success <- TRUE
        }
      }
        
      if(success){
        showModal(modalDialog(
          h3("Your file is uploaded successfully!"),
          footer = tagList(
            modalButton('OK')
          )
        ))
        seq_csv <- seq(length(input$csvs$name))
        prev_num_files <- length(uploaded_data$data)
          
        uploaded_data$csv_names[[prev_num_files + 1]] <- input$csvs$name
        uploaded_data$data[[prev_num_files + 1]] <- as.data.frame(in_file)
        updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
      }
      else{
        showModal(modalDialog(
          h3("Your file upload failed! Please check the format of your file!"),
          footer = tagList(
            modalButton('OK')
          )
        ))
      }
    })
    
    observe({
      if(length(uploaded_data$csv_names) > 1){
        for(i in 1:length(uploaded_data$csv_names)){
          if(input$select == uploaded_data$csv_names[i]){
            uploaded_data$index <- i
          }
        } 
      }
      else
        uploaded_data$index <- 1
    })

    observeEvent(input$Del,{
      index = uploaded_data$index
      uploaded_data$data <- uploaded_data$data[-index]
      uploaded_data$csv_names <- uploaded_data$csv_names[-index]
      updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
    })
    
    output$table1 <- renderDT({
      if(length(uploaded_data$data)>0){
        targ <- switch(input$row_and_col_select,
                       'rows' = 'row',
                       'columns' = 'column')
        
        datatable(uploaded_data$data[[uploaded_data$index]], selection = list(target = targ),
                  options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5)) 
      }
    })
    
    observeEvent(input$submit_delete, {
      val <- uploaded_data$index
      
      selected_rows <- as.integer(input$table1_rows_selected)
      selected_cols <- as.integer(input$table1_columns_selected)
      if (length(selected_rows) > 0) {
        uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
      }
      if (length(selected_cols) > 0) {
        uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
      }
    })
    
    observeEvent(input$viz_btn, {
      # combine all elements of uploaded$data
      # add column with station names
      uploaded_data$combined_df <- '\'visualized\''
      print(uploaded_data$combined_df)
    })
  }
  
  #
  # VISUALIZATION STUFF
  #
  {
    data <- reactiveValues(df = NULL)
    
    selectedData <- reactive({
      df_plot <- data$df[data$df$station %in% input$station,]
      event.click.data <- event_data(event = "plotly_click", source = "imgLink")
      event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
      df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                              (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]
      return(df_chosen)
    })
    
    
    
    output$main_plot = renderPlotly({
      df_plot <- data$df[data$df$station %in% input$station,]
      color_mapping <- c("1" = "red", "2" = "blue", "3" = "green", "4" = "purple", "5" = "black")
      
      # Get the minimum and maximum values of Date_Time vector
      if(length(df_plot$Date_Time) > 0){
        min_date <- min(df_plot$Date_Time)
        max_date <- max(df_plot$Date_Time)
      }else{
        min_date <- Sys.Date()
        max_date <- Sys.Date()
      }
      
      plot_ly(data = df_plot, type = 'scatter', mode = 'markers', x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~(paste0(id,"_",station)), color = ~as.character(station), colors = ~color_mapping, opacity = 0.5, source = "imgLink") %>%
        layout(xaxis = list(
          range = c(min_date, max_date),  # Set the desired range
          type = "date"  # Specify the x-axis type as date
        ), dragmode = 'select') |>
        config(modeBarButtonsToRemove = list( "pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian"))  # Remove specific buttons
      
    })
    
    output$selected_data_table <- renderDT({
      datatable(selectedData(), options = list(searching = FALSE, lengthChange = FALSE, paging = FALSE, info = FALSE, ordering = FALSE), rownames = FALSE)
      })
    
    observeEvent(input$flag_btn,{
      flag_name = paste0(input$variable_choice, "_Flag")
      data$df[((data$df$id %in% selectedData()$id) & (data$df$station %in% selectedData()$station)),flag_name] <- input$flag_type
    })
  }
  
  
  #
  # EXPORT STUFF
  #
  
  observeEvent(input$Download, {
    showModal(modalDialog(
      title = 'Are you sure you want to download the dataset below:',
      dataTableOutput('finalDT'),
      downloadButton('downloadBtn', 'Download'),
      actionButton('upload_to_gdrive', 'Upload to Google Drive'),
      easyClose = FALSE,
      footer = tagList(
        modalButton("Close")
      )
    ))
  })
  
  output$finalDT <- renderDT({
    datatable(data$df, options = list(pageLength = 20))
  })
  
  output$downloadBtn <- downloadHandler(
    filename = function() {
      # Set the filename of the downloaded file
      "flagged_data.csv"
    },
    content = function(file) {
      # Generate the content of the file
      write.csv(data$df, file, row.names = FALSE)
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
    turn_file_to_csv(data$df, name)
    res = tryCatch(upload_csv_file(data$df, name, input$drivePath), error = function(i) NA)
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
  })
}
