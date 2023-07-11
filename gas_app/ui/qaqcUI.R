varContainerUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  tagList(
    div(class = 'qaqc--type-container',
        h1(var),
        tabsetPanel(
          tabPanel('Graph',plotlyOutput(ns('main_plot'))),
          tabPanel('Summary',uiOutput(ns('summary')))
        ),
        div(class = 'qaqc--type-flag-container',
            h3('Flag Type'),
            selectInput(ns('flag_type'), label = '', choices = c('good', 'questionable', 'interesting', 'bad')),
            actionButton(ns('flag_btn'), class = 'flag-btn', 'Flag selected points')
        )
    )
  )
}

varContainerServer <- function(id, goop) {
  moduleServer(
    id,
    function(input, output, session) {
      output$summary <- renderUI({
        print(unique(goop$combined_df$Variable))
        h1('Summary would go here')
      })
      output$main_plot <- renderPlotly({
        df <- data.frame(X = c(1,2,3),
                         Y = c(5,6,75))
        print(df)
        plot_ly(data = df, type = 'scatter', mode = 'markers', 
                x = ~X, y = ~Y)
      })
    }
  )
}

div(class = 'qaqc page',
    div(class = 'qaqc--intro-container',
        div(class = 'qaqc--intro',
          p(class = 'qaqc--intro-instructions', "Instructions: Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text
  ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five 
  centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset 
  sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."),
          dateRangeInput('qaqcDateRange', 'Enter Date Range'),
          uiOutput("station"),
          uiOutput("variable_c")
        )
      ),
    div(class = 'qaqc--main',
        #varContainerUI(id = 'DO', var = 'Dissolved Oxygen (DO)'),
        #varContainerUI(id = 'CH4', var = 'Methane (CH4)')
        uiOutput('varContainers')
    )
)
