## --------------------------------------------------------------------------------------------
library(shiny)
library(plotly)
library(crosstalk)
library(DT)
library(shinyTime)

source(
  knitr::purl('updated_cleaning.R',
              output = tempfile(),
              quiet = TRUE)) #gets cleaned data

#Creates a user interface
ui <- fluidPage(
    titlePanel('Salt Slug Visualizations'), #names the browser window title

#Designs the side bar
    sidebarLayout(
      sidebarPanel(
        selectInput('station', label = 'Select station', c(1, 2, 3, 4, 5)), #5 stations to choose from
        radioButtons('radioInput',label = helpText('Select variable to graph'), #Used to visualize one of the variables when clicked
                     c('Low Range' = 'Low_Range', 'Full Range' = 'Full_Range', 'Temp C' = 'Temp_C')),
        actionButton('flag', label = 'flag bad points'), #creates a botton to flag points of interests
        actionButton('reset_flag', label = 'reset the flag for the station'), #creates a button to reset all the flags to be "good"
        hr(),
        actionButton('final',label = 'show final table'), #creates a button to show the final table
        actionButton('repaint', label = 'repaint the plot'), #creates a button to replot
        actionButton('add_salt', label = 'add slug started time') #creates a button to add the time that salt slug is added
        
    ), 
    
#Designs the main panel
      mainPanel(plotlyOutput('plotOutput'),
                dataTableOutput('selectedData'),
                dataTableOutput('finalDT'),
                textOutput("date"))
    
  )
  
)

#Creates a R session that runs code and returns results
server <- function(input, output){
 
  #Adds "Flag" columns to each variables
  data <- reactiveValues(df = combined_df |> #Creates a global variable to store the original table
                           mutate(Low_Range_Flag = 'good',
                                  Full_Range_Flag = 'good',
                                  Temp_C_Flag = 'good'), #Sets the default flags to be "good"
                         p = c()) #Creates a global variable p to store the plots
  
  #A function to generate the plot
  observe({
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    data$p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
  
  #An function to make interactive plots
  output$plotOutput <- renderPlotly({
    highlight(ggplotly(data$p), 'plotly_selected') #Enables selection on the plot
  })
  
  selectedData <- reactive({
    event <- event_data('plotly_selected')
    if (!is.null(event))
      data$df[data$df$station == as.numeric(input$station),] %>% slice(event$pointNumber + 1)
  })
  
  #Generates the table of highlighted points
  output$selectedData <- renderDataTable(
    selectedData(),
    options = list(
      pageLength = 5
    )
  )
  
  #Flags bad data
  observeEvent(input$flag,{
    flag_name = paste0(input$radioInput, "_Flag")
    data$df[flag_name] <- ifelse((data$df$id %in% selectedData()[['id']] & 
                                    data$df$station==as.numeric(input$station)), 
                                 'bad', data$df[[flag_name]])
  })
  
  #Generates a table with added flags
  observeEvent(input$final,{
    output$finalDT <- renderDataTable(gather(data$df, key='flags', 
                                             value = 'flag_values', 
                                             Low_Range_Flag, Full_Range_Flag, 
                                             Temp_C),
                                      options = list(pageLength = 5))
  })
  
  #A function to reset all the flag to the default status "good"
  observeEvent(input$reset_flag, {
    data$df <- combined_df |>
      mutate(Low_Range_Flag = 'good',
             Full_Range_Flag = 'good',
             Temp_C_Flag = 'good')
  })
  
  #A function to re-graph
  observeEvent(input$repaint, {
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    data$p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), 
                                         color = !!as.name(paste0(input$radioInput, '_Flag')))) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
  
  #A function to add the time of adding salt slug
  observeEvent(input$add_salt, {
    showModal(modalDialog( #Popping up a window to ask user the adding time
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

#Run shiny app
shinyApp(ui = ui, server = server)

