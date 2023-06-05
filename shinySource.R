library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
source(knitr::purl("stuff.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  titlePanel("Salt Slug Visualizations"),
  sidebarLayout(
    sidebarPanel(
      selectInput('station', label = 'Select station', c('All', 1, 2, 3, 4, 5)),
      radioButtons("radioInput",label = helpText('Select variable to graph'),
                   choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C'))
      ),
    mainPanel(
      tabsetPanel(type = 'tabs',
                  tabPanel('plot', 
                           plotlyOutput("plotOutput")
                           ),
                  tabPanel('table', 
                           dataTableOutput('df')
                           )
                  ),
      textOutput('text')
      
      )
  )
)

code <- "
        function(el) { 
          el.on('plotly_click', function(d) { 
            Shiny.onInputChange('txt', d.points[0].text);
          });
        }
               "

server <- function(input, output){
  
  txt <- reactive({ input$txt })
  
  output$text <- renderText({input$txt})
  
  output$plotOutput <- renderPlotly({
    if(input$station=='All'){
      df = combined_df |>
        group_by(Date_Time) |>
        summarise(Low_Range = mean(Low_Range),
        Full_Range = mean(Full_Range),
        Temp_C = mean(Temp_C))
    }
    else{
      df = clean_data_list[[as.numeric(input$station)]]
    }
    p <- ggplot(data = df, mapping = aes(x = Date_Time, y = !!as.name(input$radioInput))) +
      theme(panel.background = element_rect(fill = '#e5ecf6'), legend.position = 'None') +
      geom_line() +
      labs(x = 'Time', y = input$radioInput)
    
    ggplotly(p) %>% 
      layout(showlegend = FALSE) %>% 
      config(displayModeBar = FALSE) %>%
      onRender(code)
    
  })
  
  output$df <- renderDT(
    clean_data_list[[4]], options = list(
      pageLength = 5
    )
  )
  
}

shinyApp(ui = ui, server = server)
