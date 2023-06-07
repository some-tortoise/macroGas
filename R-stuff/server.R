library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

server <- function(input, output, session){
  
  #
  # VISUALIZATION STUFF
  #
  
  data <- reactiveValues(df = combined_df)
  
  
  selectedData <- reactive({
    df_plot <- data$df[data$df$station == as.numeric(input$station),]
    event.click.data <- event_data(event = "plotly_click", source = "imgLink")
    event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
    df_chosen <- df_plot[((df_plot$id %in% event.click.data$key) | (df_plot$id %in% event.selected.data$key)),]
    return(df_chosen)
  })
  
  output$main_plot = renderPlotly({
    df_plot <- data$df[data$df$station == input$station,]
    color_mapping <- c("1" = "red", "2" = "blue", "3" = "green", "4" = "purple", "5" = "black")
    plot_ly(data = df_plot, x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~id, color = ~as.character(station), colors = ~color_mapping, source = "imgLink") %>%
      layout(xaxis = list(
        range = c(min(df_plot$Date_Time), max(df_plot$Date_Time)),  # Set the desired range
        type = "date"  # Specify the x-axis type as date
      ), dragmode = 'select')
    
  })
  
  output$selected_data_table <- renderDT(selectedData())
  
  observeEvent(input$flag_btn,{
    flag_name = paste0(input$variable_choice, "_Flag")
    data$df[((data$df$id %in% selectedData()$id) & (data$df$station %in% selectedData()$station)),flag_name] <- input$flag_type
  })
  
  output$df <- renderDT({
    display_frame <- clean_dataframe_list[[as.numeric(input$station)]]
    display_frame$Date_Time <- format(as.POSIXct(display_frame$Date_Time), '%Y-%m-%d %H:%M:%S')
    datatable(display_frame, options = list(
      pageLength = 5
    ), rownames = FALSE)
  }
  )
  
  #
  # LOAD IN STUFF
  #
  
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
  
  #
  #DOWNLOAD STUFF
  #
  
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
