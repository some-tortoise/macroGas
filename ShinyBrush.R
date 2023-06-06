library(shiny)
library(plotly)
library(crosstalk)
library(DT)
library(shinyTime)

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
        actionButton('reset_flag', label = 'reset the flag for the station'),
        hr(),
        actionButton('final',label = 'show final table'),
        actionButton('repaint', label = 'repaint the plot'),
        actionButton('add_salt', label = 'add slug started time')
        
    ),
      
      mainPanel(plotlyOutput('plotOutput'),
                dataTableOutput('selectedData'),
                dataTableOutput('finalDT'),
                textOutput("date"))
    
  )
  
)

server <- function(input, output){
  
  data <- reactiveValues(df = combined_df |>
                           mutate(Low_Range_Flag = 'good',
                                  Full_Range_Flag = 'good',
                                  Temp_C_Flag = 'good'),
                         p = c())
  
  observe({
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    data$p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
  
  output$plotOutput <- renderPlotly({
    highlight(ggplotly(data$p), 'plotly_selected')
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
                                    data$df$station==as.numeric(input$station)), 
                                 'bad', data$df[[flag_name]])
  })
  
  observeEvent(input$final,{
    output$finalDT <- renderDataTable(gather(data$df, key='flags', 
                                             value = 'flag_values', 
                                             Low_Range_Flag, Full_Range_Flag, 
                                             Temp_C),
                                      options = list(pageLength = 5))
  })
  
  observeEvent(input$reset_flag, {
    data$df <- combined_df |>
      mutate(Low_Range_Flag = 'good',
             Full_Range_Flag = 'good',
             Temp_C_Flag = 'good')
  })
  
  observeEvent(input$repaint, {
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    data$p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), 
                                         color = !!as.name(paste0(input$radioInput, '_Flag')))) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
  
  observeEvent(input$add_salt, {
    showModal(modalDialog(
      title = "Add time of starting the slug",
      dateInput('slug_date',label='add the date(ymd)',value = "2023-05-25"),
      textInput('slug_time',label='add time(hms)', value = "12:00:00"),
      actionButton("Apply","Apply change", icon = NULL, width = NULL),
      easyClose = FALSE,
      footer = tagList(
        modalButton("Close")
      )
    ))
  })

  observeEvent(input$Apply, {
    slug_time = ymd_hms(paste(input$slug_date, input$slug_time, sep = " "), tz='GMT')
    # need to add how we want to do with the entered time
  })

}

shinyApp(ui = ui, server = server)
