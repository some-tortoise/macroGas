tags$style(
  type = 'text/css',
  '.modal-dialog { width: fit-content !important; }'
)
div(class = 'flag-panel-container panel-container',
    fluidRow(
      column(width= 3,
             HTML("<h5><b>Select station to view</b></h5>"),
             uiOutput("station"),
             uiOutput("variable_c"),
             uiOutput("start_datetime_input"),
             uiOutput("end_datetime_input"),
             selectInput('flag_type', label = 'Select flag type', c('good', 'questionable', 'interesting', 'bad')),
             actionButton('flag_btn', label = 'Flag points'),
             actionButton("Reset", label = "reset flags")
      ),
      column(width= 8,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table'),
             downloadButton('download_longer',"Download Data")
      )
    )
)
