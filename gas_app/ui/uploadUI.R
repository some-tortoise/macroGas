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
      div(class = 'upload--box1-2',
        div(class = 'upload--site-label',
            'Site'),
        uiOutput("siteNameUI")
      ),
      div(class = 'upload--box1-3',
          div(class = 'upload--station-label',
              'Station'),
          uiOutput("stationNameUI")
      ),
      actionButton("df_delete", "Add dataset")
      ),
  div(class = 'upload-box-2',
      DTOutput("contents")
      ),
  div(class = 'upload-box-3',
      p('when you have finished uploading, move on to QAQC.')
      )
  )