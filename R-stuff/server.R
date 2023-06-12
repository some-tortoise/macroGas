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
    
    uploaded_data <- reactiveValues(csv_names = NULL, 
                                    data = NULL, 
                                    station_names = NULL,
                                    combined_df = NULL)
    
    observeEvent(input$csvs, {
      seq_csv <- seq(1, length(input$csvs$name))
      prev_num_files <- length(uploaded_data$data)
      in_file <- NULL
      for(i in seq_csv){
        tryCatch({
          in_file <- read.csv(input$csvs$datapath[i],
                              header = input$header,
                              sep = input$sep,
                              quote = input$quote)
        }, error = function(e){
          in_file <- NULL
        })
        
        uploaded_data$csv_names[[prev_num_files + i]] <- input$csvs$name[i]
        uploaded_data$data[[prev_num_files + i]] <- as.data.frame(in_file)
        
      }
      
      updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
    })
    
    output$table1 <- renderDT({
      val <- 1
      for(i in seq(uploaded_data$csv_names)){
        if(input$select == uploaded_data$csv_names[i]){
          val <- i
        }
      }
      
      targ <- switch(input$row_and_col_select,
                     'rows' = 'row',
                     'columns' = 'column')
      
      datatable(uploaded_data$data[[val]], selection = list(target = targ), options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5))
    })
    
    observeEvent(input$submit_delete, {
      val <- 1
      for(i in seq(uploaded_data$csv_names)){
        if(input$select == uploaded_data$csv_names[i]){
          val <- i
        }
      }
      
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
    data <- reactiveValues(df = combined_df)
    
    
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
        ), dragmode = 'select')
      
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
  {
    output$downloadBtn <- downloadHandler(
      filename = function() {
        # Set the filename of the downloaded file
        "my_file.csv"
      },
      content = function(file) {
        # Generate the content of the file
        # In this example, we create a simple CSV file with the Iris dataset
        write.csv(uploaded_data$data, file, row.names = FALSE)
        print('File has been \'downloaded\'')
      }
    )
     
     observeEvent(input$upload_to_gdrive, {
       name <- input$csvs$name
       turn_file_to_csv(uploaded_data$data, name)
       upload_csv_file(uploaded_data$data, name)
       print('File has been \'uploaded\'')
     })
  }
}
