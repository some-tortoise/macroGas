tags$style(
  type = 'text/css',
  '.modal-dialog { width: fit-content !important; }'
)
div(class = 'flag-panel-container panel-container',
    fluidRow(
      column(width= 3,
             uiOutput("station_picker"),
             HTML("<h5><b>Select station to view</b></h5>"),
             radioButtons("variable_choice",label = helpText('Select variable to graph'),
                          choices = c("DO Conc, mg/L" = "DO_conc",  "Temp, C" = 'Temp_C')),
             uiOutput("start_datetime_input"),
             uiOutput("end_datetime_input"),
             selectInput('flag_type', label = 'Select flag type', c('good', 'questionable', 'interesting', 'bad')),
             actionButton('flag_btn', label = 'Flag points')
      ),
      column(width= 8,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table'),
             downloadButton('download_longer',"Download Data")
      )
    )
)
