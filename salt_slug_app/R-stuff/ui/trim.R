div(class = 'trim-panel-container panel-container',
        fluidRow(
      column(width= 6,
             plotlyOutput('trim_plot'),
             div(
               hr(),
               h5("The above plot displays all of the stations that you have uploaded. Please move the vertical bars around relevant breakthrough curves in order to trim out excess data.
                  The graph to the right will change based on where you choose to trim, and this data will be carried forward through the rest of the app. Please be aware that once you chooe to continue, data will have to be re-uploaded if you wish to make the selected bounds larger.")
             )
      ),
      column(width = 4,
             plotlyOutput('trimmed_plot'),
              div(
                hr(),
                h5("Once you're happy with the above trim, click below to save your changes and move on to QA/QC."),
                actionButton("continue_button2", "Continue")
              )
      )
    )
)

