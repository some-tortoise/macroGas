library(shiny)
library(plotly)
library(crosstalk)
library(DT)
source(
  knitr::purl("updated_cleaning.R",
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
    titlePanel("Salt Slug Visualizations"),
    
    sidebarLayout(
      sidebarPanel(
        selectInput('station', label = 'select the station', c('All', 1, 2, 3, 4, 5)),
        checkboxGroupInput("radioInput",label = helpText('Select variable to graph'),
                     c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
        textOutput('warning')
        
    ),
      
      mainPanel(plotlyOutput("plotOutput"),
                dataTableOutput("selectedData"))
    
  )
  
)

server <- function(input, output){
  
  data <- reactiveValues(df = combined_df,
                         avg_df = combined_df |> 
                           group_by(Date_Time) |> 
                           summarise(Low_Range = mean(Low_Range),
                                     Full_Range = mean(Full_Range),
                                     Temp_C = mean(Temp_C)) |>
                           mutate(id = 1:11804))
  
  output$plotOutput <- renderPlotly({
    if(!(("Temp_C" %in% input$radioInput) & (("Low_Range" %in% input$radioInput) | ("Full_Range" %in% input$radioInput)))){
      if(input$station=='All')
        df_plot = SharedData$new(data$avg_df)
      else
        df_plot = SharedData$new(data$df[data$df$station == as.numeric(input$station),])
      if(length(input$radioInput)==1){
        p <- ggplot(data = df_plot, aes(x = Date_Time, y = !!as.name(input$radioInput), color = 'red')) +
          theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
          geom_point() +
          geom_line() +
          labs(x = 'Time', y = input$radioInput)
        highlight(ggplotly(p), "plotly_selected")
      }
      else if(length(input$radioInput)>1){
        p <- ggplot(data = df_plot) +
          theme(panel.background = element_rect(fill = 'lightgray'), legend.position = 'None') +
          geom_point(,aes(x = Date_Time, y = !!as.name(input$radioInput[1]), color = 'red')) +
          geom_line(,aes(x = Date_Time, y = !!as.name(input$radioInput[1]), color = 'red')) +
          geom_point(,aes(x = Date_Time, y = !!as.name(input$radioInput[2]), color = 'blue')) +
          geom_line(,aes(x = Date_Time, y = !!as.name(input$radioInput[2]), color = 'blue')) +
          labs(x = 'Time', y = input$radioInput)
        highlight(ggplotly(p), "plotly_selected")
      }
    }
  })
  
  selectedData <- reactive({
    event <- event_data("plotly_selected")
    if(input$station=='All'){
      if (!is.null(event))
        data$avg_df %>% slice(event$pointNumber + 1)
    }
    else{
      if (!is.null(event))
        data$df[data$df$station == as.numeric(input$station),] %>% slice(event$pointNumber + 1)
    }
  })
  
  output$selectedData <- renderDataTable(
    selectedData(),
    options = list(
      pageLength = 5
    )
  )
  
  output$warning = renderText({
    if(("Temp_C" %in% input$radioInput) & (("Low_Range" %in% input$radioInput) | ("Full_Range" %in% input$radioInput))){
      "warning"
    }
  })
}

shinyApp(ui = ui, server = server)
