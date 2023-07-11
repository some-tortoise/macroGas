varViewUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  tagList(
    div(class = 'view--type-container',
        h1(var),
        plotlyOutput(ns('main_plot_view'))
    )
  )
}

varViewServer <- function(id, variable, goop, dateRange) {
  moduleServer(
    id,
    function(input, output, session) {
      
      output$main_plot_view <- renderPlotly({
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#FDF000", "good" = "#9EC1CF")
        plotdf_view <- goop$combined_df %>% filter(Variable == variable)
        plotdf_view <- subset(plotdf_view, Date_Time >= dateRange()[1] & Date_Time <= dateRange()[2])
        plot_ly(data = plotdf_view, type = 'scatter', mode = 'markers', 
                x = ~Date_Time, y = ~Value, color = ~as.character(Flag), key = ~(paste0(as.character(id),"_",as.character(Station))), colors = color_mapping, source = paste0("viewgraph_",variable))
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
