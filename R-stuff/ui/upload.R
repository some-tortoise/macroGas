

div(class = 'upload-panel-container panel-container blue-panel',
    #column for sidebar options
    column(width = 3,
       actionButton("uploadinstructions", "?"),
       hr(),
       h5("Data Template:"),
       downloadButton("downloadFile", "Download File"),
       br(),
       hr(),
       #two upload choices
       h5("Import data from:"),
       actionButton("gdrive_choice", "Through Google Drive"),
       actionButton("manual_choice", "Manually"),
       tags$hr(),
       conditionalPanel(
         condition = "input.gdrive_choice",
         textInput('gdrive_link', 'Google Drive Link:')
       ),
       conditionalPanel(
         condition = "input.manual_choice",
         fileInput("upload", "Choose CSV File",
                 multiple = FALSE,
                 accept = c("text/csv",
                            "text/comma-separated-values,text/plain",
                            ".csv")
                 )
         ),
       uiOutput("selectfiles"),
       actionButton("delete", "Remove selected dataset."),
       tags$hr(),
       checkboxInput("Edit_upload", "Advanced Editing", value = FALSE),
       conditionalPanel(
         condition = "input.Edit_upload",
         # numericInput('station_name','Enter station number', 0),
         radioButtons("row_and_col_select", "Choose which to edit",
                      choices = c("rows",
                                  "columns"),
                      selected = "rows"),
         actionButton('submit_delete', 'Delete selected')
         )
       ),

      #column for the output table
      column(width = 7,
        div(
          DTOutput("contents"),
            div(
               id = "conditional",
               p("Once you're happy with the uploaded files, click below to move on to ordering your stations"),
               actionButton("continue_button", "Continue")
           )
       )
      )
)
#        checkboxInput("header", "Header", FALSE),
#        radioButtons("sep", "Separator",
#           choices = c(Comma = ",",
#             Semicolon = ";" ,
#            Tab = "\t"),
#        selected = ","),
# 
# div(
# actionButton('viz_btn','Visualize'))
# )

