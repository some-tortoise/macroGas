# Generates a user interface (UI) element to display information related to a specific variable.
varContainerUI <- function (id, var = 'Unknown Variable'){
  ns <- NS(id)
  
  variable_names <- list(
    'Temp_C' = 'Temp C',
    'DO_conc' = 'DO Concentration (mg/L)',
    'Low_Range' = 'Low Range (µS/cm)',
    'Full_Range' = 'Full Range (µS/cm)',
    'High_Range' = 'High Range (µS/cm)',
    'Abs_Pres' = 'Abs Pressure (kPa)'
  )#takes variable names and creates a list of more readable versions of these variable names
  
  alias <- variable_names[var] #saves readable variable name for each variable under object alias
  
  
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

# Provides dynamic interactivity for exploring and flagging data points in the main plot while displaying summary statistics for the selected variable.
varContainerServer <- function(id, variable, goop, dateRange, pickedStation, pickedSite) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # Create reactive selectedData from goop$combined_df based on user selections
      selectedData <- reactive({
        df_plot <- goop$combined_df
        event.selected.data <- event_data(event = "plotly_selected", source = paste0("typegraph_",variable))
        df_chosen <- df_plot[(paste0(df_plot$id,'_',df_plot$Site) %in% event.selected.data$key),]
        df_chosen <- df_chosen[df_chosen$Variable == variable & df_chosen$Site == pickedSite() & df_chosen$Station == pickedStation(), ]
        return(df_chosen)
      })  
      
      # Calculate and display summary statistics
      output$summary <- renderUI({
        
        summaryFlagVal <- input$summaryFlag
        summary_df <- goop$combined_df
        if(!is.null(summaryFlagVal)){
          if(summaryFlagVal == FALSE){
            summary_df <- goop$combined_df[goop$combined_df$Flag == 'NA', ]
          }
        }else{
        }
        
       #finds the start and end date of the dataframe
        start_date_summary = min(summary_df$Date_Time)
        end_date_summary = max(summary_df$Date_Time)
      #user-entered date value for calculating summary statistics over a particular day
        summary_daily_dateValue <- input$summary_daily_date
        if(is.null(input$summary_daily_date)){
          summary_daily_dateValue <- start_date_summary
        }
        
        #user-entered date range value for calculating summary statistics over a custom date range
        summary_custom_startValue <- input$summary_custom_dateRange[1]
        if(is.null(input$summary_custom_dateRange[1])){
          summary_custom_startValue <- start_date_summary
        }
        
        summary_custom_endValue <- input$summary_custom_dateRange[2]
        if(is.null(input$summary_custom_dateRange[2])){
          summary_custom_endValue <- end_date_summary
        }
        
        #generates df for only user-selected site and station
        df <- summary_df[summary_df$Site == pickedSite() & summary_df$Station == pickedStation(),]
       
         #calculates various summary statistics for full date range available
        full_values <- df[(df$Variable == variable), 'Value']
        full_mean <- round(mean(full_values, na.rm = TRUE), 2)
        full_median <- median(full_values, na.rm = TRUE)
        full_min <- min(full_values, na.rm = TRUE)
        full_max <- max(full_values, na.rm = TRUE)
        full_sd <- round(sd(full_values, na.rm = TRUE), 2)
        list_of_full_quartiles <- c(quantile(full_values, na.rm = TRUE)[2][1],quantile(full_values, na.rm = TRUE)[3][1],quantile(full_values, na.rm = TRUE)[4][1])
        list_of_full_quartiles = round(list_of_full_quartiles, 2)
        full_quartile <- list_of_full_quartiles
        
        #calculates various summary statistics for one day at a time
        daily_values  <- df[(df$Variable == variable) & (df$Date_Time > summary_daily_dateValue & df$Date_Time < summary_daily_dateValue + 1), 'Value']
        daily_mean <- round(mean(daily_values, na.rm = TRUE), 2)
        daily_median <- median(daily_values, na.rm = TRUE)
        daily_min <- min(full_values, na.rm = TRUE)
        daily_max <- max(full_values, na.rm = TRUE)
        daily_sd <- round(sd(daily_values, na.rm = TRUE), 2)
        daily_quartile <- as.data.frame(quantile(daily_values, na.rm = TRUE))
        list_of_daily_quartiles <- c(quantile(daily_values, na.rm = TRUE)[2][1],quantile(daily_values, na.rm = TRUE)[3][1],quantile(daily_values, na.rm = TRUE)[4][1])
        list_of_daily_quartiles = round(list_of_daily_quartiles, 2)
        daily_quartile <- list_of_daily_quartiles
       
        #calculates various summary statistis for a user-entered date range
        custom_values  <- df[(df$Variable == variable) & (df$Date_Time >= summary_custom_startValue & df$Date_Time <= summary_custom_endValue), 'Value']
        custom_mean <- round(mean(custom_values, na.rm = TRUE), 2)
        custom_median <- median(custom_values, na.rm = TRUE)
        custom_min <- min(full_values, na.rm = TRUE)
        custom_max <- max(full_values, na.rm = TRUE)
        custom_sd <- round(sd(custom_values, na.rm = TRUE), 2)
        list_of_custom_quartiles <- c(quantile(custom_values, na.rm = TRUE)[2][1],quantile(custom_values, na.rm = TRUE)[3][1],quantile(custom_values, na.rm = TRUE)[4][1])
        list_of_custom_quartiles = round(list_of_custom_quartiles, 2)
        custom_quartile <- list_of_custom_quartiles
       
        #displays summary statistics
         div(class = 'summary-container',
            div(class = 'summary-flag-container',
                checkboxInput(paste0(variable,'-summaryFlag'), 'Include Flags?',value = summaryFlagVal)),
            div(class = 'summary-sub-container',
                h1('Daily'),
                p(paste0('Mean: ',daily_mean)),
                p(paste0('Median: ',daily_median)),
                p(paste0('Min: ',daily_min)),
                p(paste0('Max: ',daily_max)),
                p(paste0('Standard deviation: ', daily_sd)),
                p(paste0("25th, 50th, 75th Quartiles: "), paste0(daily_quartile, collapse=",")),
                dateInput(paste0(variable,'-summary_daily_date'), 'Date:', value = summary_daily_dateValue)
            ),
            div(class = 'summary-sub-container',
                h1('Full'),
                p(paste0('Mean: ',full_mean)),
                p(paste0('Median: ',full_median)),
                p(paste0('Min: ',full_min)),
                p(paste0('Max: ',full_max)),
                p(paste0('Standard deviation: ', full_sd)),
                p(paste0("25th, 50th, 75th Quartiles: "), paste0(full_quartile, collapse=","))
              ),
            div(class = 'summary-sub-container',
                h1('Custom'),
                p(paste0('Mean: ',custom_mean)),
                p(paste0('Median: ',custom_median)),
                p(paste0('Min: ',custom_min)),
                p(paste0('Max: ',custom_max)),
                p(paste0('Standard deviation: ', custom_sd)),
                p(paste0("25th, 50th, 75th Quartiles: "), paste0(custom_quartile, collapse=",")),
                dateRangeInput(paste0(variable,'-summary_custom_dateRange'), 'Date Range:', start = summary_custom_startValue, end = summary_custom_endValue, min = summary_custom_startValue, max = summary_custom_endValue)
              )
            )
        
      }) 
      
      # Assign respective flags user selects in goop$combined_df
      observeEvent(input$flag_btn, {
        goop$combined_df[(goop$combined_df$id %in% selectedData()$id), "Flag"] <- input$flag_type  
      }) 
      
      output$main_plot <- renderPlotly({
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#601A3E", "NA" = "#9EC1CF")
        plot_df <- goop$combined_df[goop$combined_df$Variable == variable,]
        plot_df <- plot_df[plot_df$Date_Time >= dateRange()[1] & plot_df$Date_Time <= dateRange()[2],]
        plot_df <- plot_df[plot_df$Station == pickedStation(),]
        plot_df <- plot_df[plot_df$Site == pickedSite(),]

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
          config(displaylogo = FALSE, modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian")) |>
          layout(plot_bgcolor='white', xaxis = list(title = 'Date Time'), yaxis = list(title = alias))
      }) #main plot
    }
  )
} 

#
# BASIC UI
#

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
          actionButton('qaqcSave', 'Save to Google Drive')
        )
      ),
    div(class = 'qaqc--main',
        uiOutput('varContainers')
    )
)
