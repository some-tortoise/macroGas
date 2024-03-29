# Creates a dropdown UI element for guessing a value from a list of choices. 
guessUI <- function (id, colName, guess, guessList){ 
  ns <- NS(id)
 
  tagList(
    div(class = 'guess-el',
      p(colName),
      selectInput(ns('guessInput'), label='', choices = guessList, selected = guess)
    )
  )
} 

# Defines the server-side logic for the guessUI module. When a user makes a selection in the dropdown created by the guessUI, 
# the server will capture this selection and update the corresponding position in the goop object with the selected value. 
# guessIndex specifies the position/index where the value will be saved.
guessServer <- function(id, goop, guessIndex) {
  moduleServer(
    id,
    function(input, output, session) {
      observeEvent(input$guessInput, {
        goop$guessList[guessIndex] <- input$guessInput
      })
      return(goop$guessList[guessIndex])
    }
    
      )
} 

#
# BASIC UI
#

div(class = 'upload page',
  div(class = 'upload-box-1',
      div(class = 'upload--box1-1',
        div('Choose a CSV file'),
        fileInput("df_upload", "",
                  multiple = FALSE,
                  accept = c("text/csv",
                             "text/comma-separated-values,text/plain",
                             ".csv")
        )
      ),
      div(class = 'upload--box1-15',
          checkboxInput('skipRow', 'Skip First Row', value = TRUE)
      ),
      div(class = 'upload--aBox',
        div(class = 'upload--box1-2',
          div(class = 'upload--site-label',
              'Site'),
          uiOutput("siteNameUI")
        ),
        div(class = 'upload--box1-3',
            div(class = 'upload--station-label',
                'Station'),
            uiOutput("stationNameUI")
        )
      ),
      actionButton("uploadBtn", "Add dataset")
      ),
  div(class = 'upload-box-2',
      uiOutput("guesses")
  ),
  div(class = 'upload-box-3',
      DTOutput("contents")
      ),
  div(class = 'upload-box-4',
      p('when you have finished uploading, move on to QAQC.')
      )
  )