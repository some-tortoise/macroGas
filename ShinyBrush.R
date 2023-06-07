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


## --------------------------------------------------------------------------------------------
# Creating a user interface
ui <- fluidPage(
    titlePanel('Salt Slug Visualizations'), # This is the browser window title

    # Designing the side bar
    sidebarLayout(
      sidebarPanel(
        selectInput('station', label = 'Select Station', c(1, 2, 3, 4, 5)), # 5 stations to choose from
        radioButtons('radioInput',label = helpText('Select Variable to Graph'), # To visualize one of the variables if presssed
                     c('Low Range' = 'Low_Range', 'Full Range' = 'Full_Range', 'Temp C' = 'Temp_C')),
        actionButton('flag', label = 'Flag Bad Points'), #creates a button to flag questionable points
        actionButton('reset_flag', label = 'Reset the Flags for the Station'), #creates a button to reset all the flags to be "good"
        hr(),
        actionButton('final',label = 'Show Final Table'), #creates a button to show the final table
        actionButton('repaint', label = 'Repaint the Plot'), #creates a button to re-plot
        actionButton('add_salt', label = 'Add Slug Started Time') #creates a button to add the time that the salt slug was added
    ), 
    
      # Designing the main panel
      mainPanel(plotlyOutput('plotOutput'),
                dataTableOutput('selectedData'),
                dataTableOutput('finalDT'),
                textOutput("date"))
  )
)


## --------------------------------------------------------------------------------------------
# Creating a R session that runs code and returns results
server <- function(input, output){
 
  # Adding "Flag" columns to each variables
  data <- reactiveValues(df = combined_df |> #Creates a global variable 'df' to store the original table
                           mutate(Low_Range_Flag = 'good',
                                  Full_Range_Flag = 'good',
                                  Temp_C_Flag = 'good'), #Sets the default flags to be "good"
                         p = c()) #Creates a global variable 'p' to store the plots
  
  # A function to generate the plot
  observe({
    df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
    data$p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
      theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
      geom_point() +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
  })
  
  # A function to make interactive plots
  output$plotOutput <- renderPlotly({
    highlight(ggplotly(data$p), 'plotly_selected') #Enables selection on the plot
  })
  
  selectedData <- reactive({
    event <- event_data('plotly_selected')
    if (!is.null(event))
      data$df[data$df$station == as.numeric(input$station),] %>% slice(event$pointNumber + 1)
  })
  
  # Generates the table of highlighted points
  output$selectedData <- renderDataTable(
    selectedData(),
    options = list(
      pageLength = 5
    )
  )
  
  # Flags bad data
  observeEvent(input$flag, {
  # Display a confirmation dialog
  showModal(
    modalDialog(
      title = "Flag Data",
      "Are you sure you want to flag those data?",
      footer = tagList(
        actionButton("confirm_flag", "Confirm", class = "btn-primary"),
        modalButton("Cancel")
      )
    )
  )
})

observeEvent(input$confirm_flag, {
  # Flag the data if confirmed
  flag_name <- paste0(input$radioInput, "_Flag")
  data$df[flag_name] <- ifelse((data$df$id %in% selectedData()[['id']] &
                                 data$df$station == as.numeric(input$station)),
                              'bad', data$df[[flag_name]])
  removeModal()
  shinyalert::alert("Data Flagged", type = "success")
})

  # Generates a table with flags
  observeEvent(input$final,{
    output$finalDT <- renderDataTable(gather(data$df, key='flags', 
                                             value = 'flag_values', 
                                             Low_Range_Flag, Full_Range_Flag, 
                                             Temp_C),
                                      options = list(pageLength = 5))
  })
  
  # A function to reset all the flags
  observeEvent(input$reset_flag, {
  # Display a confirmation dialog
  showModal(
    modalDialog(
      title = "Reset Flags",
      "Are you sure you want to reset all the flags?",
      footer = tagList(
        actionButton("confirm_reset", "Confirm", class = "btn-primary"),
        modalButton("Cancel")
      )
    )
  )
})

observeEvent(input$confirm_reset, {
  # Reset the flags if confirmed
  data$df <- combined_df |>
    mutate(
      Low_Range_Flag = 'good',
      Full_Range_Flag = 'good',
      Temp_C_Flag = 'good'
    )
  removeModal()
  shinyalert::alert("Flags Reset", type = "success")
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
  
  #A function to input the salt slug adding time
  observeEvent(input$add_salt, {
    showModal(modalDialog( #Popping up a window to ask user to input date & time
      title = "Input Date and Time of Adding the Salt Slug",
      dateInput('slug_date',label='Add date (ymd)',value = "2023-05-25"),
      textInput('slug_time',label='Add time (hms)', value = "12:00:00"),
      actionButton("Apply","Apply Change", icon = NULL, width = NULL),
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


## --------------------------------------------------------------------------------------------
#Run shiny app
shinyApp(ui = ui, server = server)


## --------------------------------------------------------------------------------------------
library(knitr)

# Set the path to your .Rmd file
rmd_file <- "~/Desktop/r4ds/ShinyBrush.Rmd"

# Specify the output file path for the .R script
r_script <- "~/Desktop/r4ds/ShinyBrush.R"

# Use purl() to convert .Rmd to .R script
purl(rmd_file, output = r_script)


