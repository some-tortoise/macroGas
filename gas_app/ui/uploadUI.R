div(class = 'upload page',
  div(class = 'upload-box-1',
      fileInput("df_upload", "Choose a CSV file",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
                ),
      selectInput("df_select",'Your uploaded files', NULL, choices = NULL, width = "100%"),
      actionButton("df_delete", "Remove selected dataset")
      ),
  div(class = 'upload-box-2',
      DTOutput("contents")),
  div(class = 'upload-box-3',
      p('when you have finished uploading, move on to QAQC.'))
  )