library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

code <- "
        function(el) { 
          el.on('plotly_click', function(d) { 
            Shiny.onInputChange('txt', d.points[0].text);
          });
        }"

server <- function(input, output, session){
  
  txt <- reactive({ input$txt })
  
  output$choose_flag <- renderText({
    hide("choose_flag")
    return('')
  })
  
  output$clicked <- renderDT({
    if(is.null(input$txt)){
      return()
    }else{
      show("choose_flag")
      point_clicked <- str_split_1(input$txt, ' ')
      date_and_time_clicked <- paste(point_clicked[2], str_replace(point_clicked[3], '<br', ''))
      data <- combined_df[combined_df$Date_Time == date_and_time_clicked & combined_df$station == as.numeric(input$station),]
      data$Date_Time <- format(as.POSIXct(data$Date_Time), '%Y-%m-%d %H:%M:%S')
      datatable(data, options = list(searching = FALSE, lengthChange = FALSE, paging = FALSE, info = FALSE, ordering = FALSE), rownames = FALSE)
      
    }
  })
  
  output$plotOutput <- renderPlotly({
    curr_df = clean_dataframe_list[[as.numeric(input$station)]]
    p <- ggplot(data = curr_df, mapping = aes_string(x = 'Date_Time', y = input$variable_choice)) +
      theme(panel.background = element_rect(fill = '#e5ecf6'), legend.position = 'None') +
      geom_line() +
      labs(x = 'Time', y = input$variable_choice)
    
    ggplotly(p) %>% 
      layout(showlegend = FALSE) %>% 
      #config(displayModeBar = FALSE) %>%
      onRender(code)
    
  })
  
  output$df <- renderDT({
    display_frame <- clean_dataframe_list[[as.numeric(input$station)]]
    display_frame$Date_Time <- format(as.POSIXct(display_frame$Date_Time), '%Y-%m-%d %H:%M:%S')
    datatable(display_frame, options = list(
      pageLength = 5
    ), rownames = FALSE)
  }
  )
  
  uploaded_data <- reactiveValues()
  
  observeEvent(c(input$file1, input$header), {
    req(input$file1)
    tryCatch({
      data <- read.csv(input$file1$datapath,
                       header = input$header,
                       sep = input$sep,
                       quote = input$quote)
      if (ncol(data) > length(colnames(data))) {
        print('more cols than col names')
        stop("Number of columns is greater than the number of column names.")
      }
      uploaded_data$data <- data
    }, error = function(e) {
      uploaded_data$data <- NULL
    })
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
  
  output$table1 <- DT::renderDataTable({
    req(input$file1)
    
    targ <- switch(input$row_and_col_select,
                   'rows' = 'row',
                   'columns' = 'column')
    datatable(uploaded_data$data, extensions = 'Select', selection = list(target = targ), options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5)) 
  })
  
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
     name <- input$file1$name
     turn_file_to_csv(uploaded_data$data, name)
     upload_csv_file(uploaded_data$data, name)
     print('File has been \'uploaded\'')
   })
}
