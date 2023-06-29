div(class = 'trim-panel-container panel-container',
    fluidRow(
      column(width= 4,
            uiOutput("station_picker")
      ),
      column(width = 7,
             plotlyOutput('trim_plot'))
    )
)