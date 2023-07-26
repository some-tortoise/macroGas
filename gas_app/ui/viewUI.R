varViewUI <- function (id, var = 'Unknown Variable'){
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
    div(class = 'view--type-container',
        h1(alias),
        plotlyOutput(ns('main_plot_view'))
    )
  )
} ##generates a user interface (UI) element to display information related to a specific variable.

varViewServer <- function(id, variable, goop, dateRange, pickedSite, pickedStation) {
  moduleServer(
    id,
    function(input, output, session) {
      
      output$main_plot_view <- renderPlotly({
        print('hello there')
        color_mapping <- c("bad" = "#FF6663", "interesting" = "#FEB144", "questionable" = "#601A3E", "NA" = "#9EC1CF")
        plotdf_view <- goop$processed_df %>% filter(Variable == variable)
        
        plotdf_view <- plotdf_view[plotdf_view$Site == pickedSite() & plotdf_view$Station == pickedStation(), ]
        plotdf_view <- subset(plotdf_view, Date_Time >= dateRange()[1] & Date_Time <= dateRange()[2])
  
        plot_ly(data = plotdf_view, 
                type = 'scatter', 
                mode = 'markers', 
                x = ~Date_Time, 
                y = ~Value, 
                color = ~as.character(Flag), 
                key = ~(paste0(as.character(id),"_",as.character(Site))), 
                colors = color_mapping, 
                source = paste0("viewgraph_",variable)) |>
          config(displaylogo = FALSE, modeBarButtonsToRemove = list("pan2d", "hoverCompareCartesian", "lasso2d", "autoscale", "hoverClosestCartesian", "select")) 
      })
    }
  )
} #sets up a server-side logic for the varViewServer module, which generates a plot for a specific variable based on user-selected site, station, and date range. Plot displays flagged points.

div(class = 'view page',
    div(class = 'view--pick-container',
        div(class = 'view--pick',
            uiOutput('viewSiteStationSelects')
        )
    ),
    div(class = 'view--intro-container',
        div(class = 'view--intro',
            p(class = 'view--intro-instructions', "Select the date range you would like to view data from"),
            uiOutput('viewDateRange')
        )
    ),
    div(class = 'view--main',
        uiOutput('varViewContainers')
    )
)
