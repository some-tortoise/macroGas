varViewUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  tagList(
    div(class = 'view--type-container',
        h1(var),
        plotlyOutput(ns('main_plot_view'))
    )
  )
}

varViewServer <- function(id, variable, goop) {
  moduleServer(
    id,
    function(input, output, session) {
      output$main_plot_view <- renderPlotly({
        plotdf_view <- goop$combined_df %>% filter(Variable == variable)
        plot_ly(data = plotdf_view, type = 'scatter', mode = 'markers', 
                x = ~Date_Time, y = ~Value)
      })
    }
  )
}

div(class = 'view page',
    div(class = 'view--intro-container',
        div(class = 'view--intro',
            p(class = 'view--intro-instructions', "Select the date range you would like to view data from"),
            dateRangeInput('viewDateRange', 'Enter Date Range')
        )
    ),
    div(class = 'view--main',
        uiOutput('varViewContainers')
    )
)
