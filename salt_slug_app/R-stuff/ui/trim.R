tags$style(
  type = 'text/css',
  '.modal-dialog { width: fit-content !important; }'
)
div(class = 'trim-panel-container panel-container',
    fluidRow(
      column(width= 4,
            uiOutput("station_picker")
      ),
      column(width = 7,
             plotlyOutput('trim_plot'))
    )
)