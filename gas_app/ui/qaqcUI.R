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

varContainerServer <- function(id, variable, goop, dateRange) {
  moduleServer(
    id,
    function(input, output, session) {
      
      selectedData <- reactive({
        df_plot <- goop$combined_df
        #event.click.data <- event_data(event = "plotly_click", source = paste0("typegraph_",variable))
        event.selected.data <- event_data(event = "plotly_selected", source = paste0("typegraph_",variable))
        df_chosen <- df_plot[(paste0(df_plot$id,'_',df_plot$Station) %in% event.selected.data$key),]
        df_chosen <- df_chosen[df_chosen$Variable == variable,]
        
        return(df_chosen)
      }) 
      
      output$summary <- renderUI({
        print(unique(goop$combined_df$Variable))
        h1('Summary would go here')
      })
      
      observeEvent(input$flag_btn, {
        View(goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station))])
        goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station)), "Flag"] <- input$flag_type  # Set the flag
      })
      
      output$main_plot <- renderPlotly({
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#FDF", "good" = "#9EC1CF")
        filteredData <- goop$combined_df
        plot_df = filteredData %>% filter(Variable == variable)
        plot_df <- subset(plot_df, Date_Time >= dateRange()[1] & Date_Time <= dateRange()[2])
        plot_ly(data = plot_df, type = 'scatter', mode = 'markers', 
                x = ~Date_Time, y = ~Value, color = ~as.character(Flag), key = ~(paste0(as.character(id),"_",as.character(Station))), colors = color_mapping, source = paste0("typegraph_",variable)) |>
          layout(xaxis = list(
            type = "date"  # Specify the x-axis type as date
          ), dragmode = 'select') |>
          config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
          layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = variable))
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
          dateRangeInput('qaqcDateRange', 'Enter Date Range')
        )
      ),
    div(class = 'qaqc--main',
        uiOutput('varContainers')
    )
)
