library(shiny)
library(plotly)
library(crosstalk)
library(DT)
source(
  knitr::purl('updated_cleaning.R',
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel('Salt Slug Visualizations'),
    
    sidebarLayout(
      sidebarPanel(
        selectInput('station', label = 'select the station', c(1, 2, 3, 4, 5)),
        radioButtons('radioInput',label = helpText('Select variable to graph'),
                     c('Low Range' = 'Low_Range', 'Full Range' = 'Full_Range', 'Temp C' = 'Temp_C')),
        actionButton('flag', label = 'flag bad points'),
        actionButton('final',label = 'show final table'),
        actionButton('reset_flag', label = 'reset the flag for the station')
        
    ),
      
      mainPanel(plotlyOutput('plotOutput'),
                dataTableOutput('selectedData'),
                dataTableOutput('finalDT'))
    
  )
  
)

server <- function(input, output){
  
  data <- reactiveValues(df = combined_df |>
                           mutate(Low_Range_Flag = 'good',
                                  Full_Range_Flag = 'good',
                                  Temp_C_Flag = 'good'))
  
  output$plotOutput <- renderPlotly({
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput))) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      #geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
    highlight(ggplotly(p), 'plotly_selected')
  })
  
  selectedData <- reactive({
    event <- event_data('plotly_selected')
    if (!is.null(event))
      data$df[data$df$station == as.numeric(input$station),] %>% slice(event$pointNumber + 1)
  })
  
  output$selectedData <- renderDataTable(
    selectedData(),
    options = list(
      pageLength = 5
    )
  )
  
  observeEvent(input$flag,{
    flag_name = paste0(input$radioInput, "_Flag")
    data$df[flag_name] <- ifelse((data$df$id %in% selectedData()[['id']] & 
                                    data$df$station==as.numeric(input$station)), 'bad', data$df[[flag_name]])
  })
  
  observeEvent(input$final,{
    output$finalDT <- renderDataTable(data$df['Low_Range_Flag'], options = list(pageLength = 5))
  })
  
  observeEvent(input$reset_flag,{
    data$df <- combined_df |>
      mutate(Low_Range_Flag = 'good',
             Full_Range_Flag = 'good',
             Temp_C_Flag = 'good')
  })
}

shinyApp(ui = ui, server = server)
