varContainerUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  
  variable_names <- list(
    'Temp_C' = 'Temp C',
    'DO_conc' = 'DO Concentration'
  )
  
  alias <- variable_names[var]
  
  
  tagList(
    div(class = 'qaqc--type-container',
        h1(alias),
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
        full_values <- goop$combined_df[(goop$combined_df$Variable == variable), 'Value']
        custom_values  <- goop$combined_df[(goop$combined_df$Variable == variable) & (goop$combined_df$Date_Time >= input$summary_custom_dateRange[1] & goop$combined_df$Date_Time <= input$summary_custom_dateRange[2]), 'Value']
        full_mean <- round(mean(full_values, na.rm = TRUE), 2)
        full_median <- median(full_values, na.rm = TRUE)
        custom_mean <- round(mean(custom_values, na.rm = TRUE), 2)
        custom_median <- median(custom_values, na.rm = TRUE)
        full_sd <- sd(full_values, na.rm = TRUE)
        custom_sd <- sd(custom_values, na.rm = TRUE)
        start_date_summary = min(goop$combined_df$Date_Time)
        end_date_summary = max(goop$combined_df$Date_Time)
        
        div(class = 'summary-container',
            div(class = 'summary-sub-container',
                h1('Full'),
                p(paste0('Mean: ',full_mean)),
                p(paste0('Median: ',full_median)),
                p(paste0('Standard deviation: ', full_sd))
              ),
            div(class = 'summary-sub-container',
                h1('Custom'),
                p(paste0('Mean: ',custom_mean)),
                p(paste0('Median: ',custom_median)),
                p(paste0('Standard deviation: ', custom_sd)),
                dateRangeInput('summary_custom_dateRange', 'Date Range:', start = start_date_summary, end = end_date_summary)
              )
            )
        
      })
      
      observeEvent(input$flag_btn, {
        View(goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station))])
        goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Station %in% selectedData()$Station)), "Flag"] <- input$flag_type  # Set the flag
      })
      
      output$main_plot <- renderPlotly({
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#FFDFFF", "good" = "#9EC1CF")
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
          p(class = 'qaqc--intro-instructions', "Instructions: Once you have uploaded your data, the variables will appear below. Select the ‘Summary’ tabset to view summary statistics of each variable.
                                                To flag points, make sure that the ‘box select’ option is selected in the top right of graph. Once you have box selected the points you would like to flag, 
                                                select from ‘interesting’, ‘bad’, or ‘questionable’ and select ‘Flag selected points’. The flagged points will appear in a new color on the graph. 
                                                To remove flagged points, repeat the same process but set the flag type to ‘good’. For more precise flagging, utilize the zoom features in the top right of the graph before box selecting points."),
          uiOutput('qaqcDateRange')
        )
      ),
    div(class = 'qaqc--main',
        uiOutput('varContainers')
    )
)
