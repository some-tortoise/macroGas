varContainerUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  
  variable_names <- list(
    'Temp_C' = 'Temp C',
    'DO_conc' = 'DO Concentration (mg/L)',
    'Low_Range' = 'Low Range (µS/cm)',
    'Full_Range' = 'Full Range (µS/cm)',
    'High_Range' = 'High Range (µS/cm)',
    'Abs_Pres' = 'Abs Pressure (kPa)'
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
            selectInput(ns('flag_type'), label = '', choices = c('NA', 'questionable', 'interesting', 'bad')),
            actionButton(ns('flag_btn'), class = 'flag-btn', 'Flag selected points')
        )
    )
  )
}

varContainerServer <- function(id, variable, goop, dateRange, pickedStation, pickedSite) {
  moduleServer(
    id,
    function(input, output, session) {
      
      selectedData <- reactive({
        df_plot <- goop$combined_df
        #event.click.data <- event_data(event = "plotly_click", source = paste0("typegraph_",variable))
        event.selected.data <- event_data(event = "plotly_selected", source = paste0("typegraph_",variable))
        df_chosen <- df_plot[(paste0(df_plot$id,'_',df_plot$Site) %in% event.selected.data$key),]
        df_chosen <- df_chosen[df_chosen$Variable == variable & df_chosen$Site == pickedSite() & df_chosen$Station == pickedStation(), ]
        return(df_chosen)
      }) 
      
      output$summary <- renderUI({
        
        start_date_summary = min(goop$combined_df$Date_Time)
        end_date_summary = max(goop$combined_df$Date_Time)
        
        summary_daily_dateValue <- input$summary_daily_date
        if(is.null(input$summary_daily_date)){
          summary_daily_dateValue <- start_date_summary
        }
        
        summary_custom_startValue <- input$summary_custom_dateRange[1]
        if(is.null(input$summary_custom_dateRange[1])){
          summary_custom_startValue <- start_date_summary
        }
        
        summary_custom_endValue <- input$summary_custom_dateRange[2]
        if(is.null(input$summary_custom_dateRange[2])){
          summary_custom_endValue <- end_date_summary
        }
        
        full_values <- goop$combined_df[(goop$combined_df$Variable == variable), 'Value']
        full_mean <- round(mean(full_values, na.rm = TRUE), 2)
        full_median <- median(full_values, na.rm = TRUE)
        full_sd <- round(sd(full_values, na.rm = TRUE), 2)
        
        daily_values  <- goop$combined_df[(goop$combined_df$Variable == variable) & (goop$combined_df$Date_Time == summary_daily_dateValue), 'Value']
        daily_mean <- round(mean(daily_values, na.rm = TRUE), 2)
        daily_median <- median(daily_values, na.rm = TRUE)
        daily_sd <- round(sd(daily_values, na.rm = TRUE), 2)
        
        custom_values  <- goop$combined_df[(goop$combined_df$Variable == variable) & (goop$combined_df$Date_Time >= summary_custom_startValue & goop$combined_df$Date_Time <= summary_custom_endValue), 'Value']
        custom_mean <- round(mean(custom_values, na.rm = TRUE), 2)
        custom_median <- median(custom_values, na.rm = TRUE)
        custom_sd <- round(sd(custom_values, na.rm = TRUE), 2)
        
        div(class = 'summary-container',
            div(class = 'summary-flag-container',
                checkboxInput(paste0(variable,'-summaryFlag'), 'Include Flags?')),
            div(class = 'summary-sub-container',
                h1('Daily'),
                p(paste0('Mean: ',daily_mean)),
                p(paste0('Median: ',daily_median)),
                p(paste0('Standard deviation: ', daily_sd)),
                dateInput(paste0(variable,'-summary_daily_date'), 'Date:', value = summary_daily_dateValue)
            ),
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
                dateRangeInput(paste0(variable,'-summary_custom_dateRange'), 'Date Range:', start = summary_custom_startValue, end = summary_custom_endValue)
              )
            )
        
      }) #summary statistics
      
      observeEvent(input$flag_btn, {
        #View(goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$Location %in% selectedData()$Location))])
        goop$combined_df[(goop$combined_df$id %in% selectedData()$id), "Flag"] <- input$flag_type  # Set the flag
        View(goop$combined_df[(goop$combined_df$id %in% selectedData()$id),])
      })
      
      output$main_plot <- renderPlotly({
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#FFDFFF", "NA" = "#9EC1CF")
        plot_df <- goop$combined_df[goop$combined_df$Variable == variable,]
        plot_df <- plot_df[plot_df$Date_Time >= dateRange()[1] & plot_df$Date_Time <= dateRange()[2],]
        plot_df <- plot_df[plot_df$Station == pickedStation(),]
        plot_df <- plot_df[plot_df$Site == pickedSite(),]
      
        #plot_df <- plot_df[plot_df$Station == input$qaqcStationSelect,]
        # plot_df <- subset( %>% filter(Variable == variable, Site == input$qaqcSiteSelect, Station == input$qaqcStationSelect), 
        #                   Date_Time >= dateRange()[1] & Date_Time <= dateRange()[2])
        View(plot_df)
        print(as.character(unique(plot_df$Flag)))
        plot_ly(data = plot_df, 
                type = 'scatter', 
                mode = 'markers', 
                x = ~Date_Time, 
                y = ~Value, 
                color = ~as.character(Flag), 
                key = ~paste0(as.character(id),'_',as.character(Site)), 
                colors = color_mapping, 
                source = paste0("typegraph_",variable)) |>
          layout(xaxis = list(
            type = "date"  # Specify the x-axis type as date
          ), dragmode = 'select') |>
          config(modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
          layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = ~Variable))
      }) #main plot
    }
  )
}

div(class = 'qaqc page',
    div(class = 'qaqc--pick-container',
        div(class = 'qaqc--pick',
            uiOutput('qaqcSiteStationSelects')
            )
        ),
    div(class = 'qaqc--intro-container',
        div(class = 'qaqc--intro',
          p(class = 'qaqc--intro-instructions', "Instructions: Once you have uploaded your data, the variables will appear below. Select the ‘Summary’ tabset to view summary statistics of each variable.
                                                To flag points, make sure that the ‘box select’ option is selected in the top right of graph. Once you have box selected the points you would like to flag, 
                                                select from ‘interesting’, ‘bad’, or ‘questionable’ and select ‘Flag selected points’. The flagged points will appear in a new color on the graph. 
                                                To remove flagged points, repeat the same process but set the flag type to ‘NA’. For more precise flagging, utilize the zoom features in the top right of the graph before box selecting points."),
          uiOutput('qaqcDateRange'),
          p('When you are finished flagging, save your data.'),
          actionButton('qaqcSave', 'Save')
        )
      ),
    div(class = 'qaqc--main',
        uiOutput('varContainers')
    )
)
