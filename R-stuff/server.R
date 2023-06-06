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

server <- function(input, output){
  
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
      config(displayModeBar = FALSE) %>%
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
  
  observeEvent(input$file1, {
    # Generate a temporary file name
    temp_file <- tempfile()
    
    # Write data to the temporary file
    writeLines("Hello, temporary file!", temp_file)
    
    # Read and modify the contents of the temporary file
    file_content <- readLines(temp_file)
    modified_content <- paste0(file_content, " It's been altered!")
    
    # Overwrite the contents of the temporary file
    writeLines(modified_content, temp_file)
    
    # Print the modified contents
    cat("Modified file content:\n")
    cat(readLines(temp_file), "\n")
    
    # Cleanup: Remove the temporary file
    unlink(temp_file)
  })
  
  output$table1 <- DT::renderDataTable({
    req(input$file1)
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote)
    
    targ <- switch(input$row_and_col_select,
                   'rows' = 'row',
                   'columns' = 'column')
    
    datatable(df, extensions = 'Select', selection = list(target = targ), options = list(ordering = FALSE, searching = FALSE, pageLength = 5))
  })
  
  output$table2 <- DT::renderDataTable({
    req(input$file1)
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote)
    
    if(!is.null(input$table1_rows_selected)){
      req(input$table1_rows_selected)
      subset_table <- df[, -input$table1_rows_selected, drop = F]
    }else{
      req(input$table1_columns_selected)
      subset_table <- df[, -input$table1_columns_selected, drop = F]
    }
    datatable(subset_table)
  })
}