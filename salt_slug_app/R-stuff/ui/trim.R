fluidPage(
    div(class = 'trim-panel-container panel-container',
        fluidRow(
<<<<<<< Updated upstream
      column(width= 7,
             uiOutput("station_picker"),
             plotlyOutput('trim_plot')
      ),
      column(width = 4,
             plotlyOutput('trimmed_plot'),
              div(
                hr(),
                h5("After adjusting the vertical bars so that only relevant data is within them, click below to save your changes and move on to QA/QC."),
                actionButton("continue_button2", "Continue")
              )
      )
=======
          column(width = 7,
                 plotlyOutput('trim_plot'),
                 div(
                   hr(),
                   h5("The above plot displays all of the stations that you have uploaded. Please move the vertical bars to trim out excess data from your graph like so. The graph to the right will change based on where you choose to trim, and this data will be carried forward through the rest of the app.")
                 )
          ),
          column(width = 4,
                 plotlyOutput('trimmed_plot'),
                 div(
                   hr(),
                   h5("If you're happy with the above trim, click below to save your changes and move on to QA/QC."),
                   actionButton("continue_button2", "Continue")
                 )
          )
        )
>>>>>>> Stashed changes
    )
  )

