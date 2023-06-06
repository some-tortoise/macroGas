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
        }
               "

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
    df = clean_dataframe_list[[as.numeric(input$station)]]
    p <- ggplot(data = df, mapping = aes_string(x = 'Date_Time', y = input$variable_choice)) +
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
  
}