div(class = 'trim-panel-container panel-container',
    fluidRow(
      column(width= 4,
            uiOutput("station_picker")
      ),
      column(width = 7,
             plotlyOutput('trim_plot'),
              div(
                hr(),
                h5("After adjusting the vertical bars so that only relevant data is within them, click below to save your changes and move on to QA/QC."),
                actionButton("continue_button2", "Continue")
              )
      )
    )
)

