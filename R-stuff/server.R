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
    uploaded_data <- reactiveValues(data = NULL, names = NULL)
    
    observeEvent(input$csvs, {
      req(input$csvs)
      
      tryCatch({
        in_files <- read.csv(input$csvs$datapath,
                         header = input$header,
                         sep = input$sep,
                         quote = input$quote)
        uploaded_data$names <- c(uploaded_data$names, input$csvs$name)
        uploaded_data$data <- in_files
      }, error = function(e) {
        uploaded_data$data <- NULL
      })
    })
    
    dynamicElements <- reactiveVal(NULL)
    
    oldList <- reactiveValues(a = NULL)
    
    observeEvent(input$dataFromJS, {
      print('aaaa')
    })
    
    observeEvent(input$csvs, {
      uploaded_data$names <- unique(c(uploaded_data$names, input$csvs$name))
      session$sendCustomMessage("names", uploaded_data$names)
      for(i in uploaded_data$names[!(uploaded_data$names %in% oldList$a)]){
        newElement <- tagList(
          div(class = 'created-div',
              strong(i, class = "dynamic-h3"),
              actionButton('remove_file',class = 'del-btn','X')
          ),
          # Add more UI components here as needed
        )
        
        currentElements <- dynamicElements()
        updatedElements <- tagList(currentElements, newElement)
        
        dynamicElements(updatedElements)
      }
      oldList$a <- uploaded_data$names
      
    })
    
    output$dynamicUI <- renderUI({
      dynamicElements()
    })
    
    output$table1 <- DT::renderDataTable({
      req(input$csvs)
      
      targ <- switch(input$row_and_col_select,
                     'rows' = 'row',
                     'columns' = 'column')
      datatable(uploaded_data$data, selection = list(target = targ), options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5)) 
    })
    
    observeEvent(input$submit_delete, {
      selected_rows <- as.integer(input$table1_rows_selected)
      selected_cols <- as.integer(input$table1_columns_selected)
      if (length(selected_rows) > 0) {
        uploaded_data$data <- uploaded_data$data[-selected_rows, ]
      }
      if (length(selected_cols) > 0) {
        uploaded_data$data <- uploaded_data$data[, -selected_cols]
      }
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
