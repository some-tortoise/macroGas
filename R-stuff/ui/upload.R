
div(class = 'upload-panel-container panel-container',
    #column for sidebar options
    column(width = 3,

       actionButton("uploadinstructions", "?"),
       h4("Instruction",
          bsButton("q1", label = "", icon = icon("question"), style = "info", size = "extra-small")),
       bsPopover(id = "q1", title = "Instruction",
                 content = paste0("Click the \\'Download File\\' button to see the required format.",
                                  "Select your CSV file by clicking \\'Choose CSV File\\' and then Open to upload it.",
                                  "The uploaded file will be displayed in the table below.",
                                  "To delete a file, click the \\'Delete\\' button.",
                                  "For futher editing here, click the \\'Advanced Editing\\' botton.",
                                  "Click the ? icon for help anytime!"),
                 placement = "right", 
                 trigger = "focus",
                 options = list(container = "body")
       ),
       hr(),
       h5("Data Template:"),
       downloadButton("downloadFile", "Download File"),
       br(),
       hr(),
       #two upload choices
       h5("Import data from:"),
       radioButtons("upload_m", "Choose how to upload data", c("Google Drive", "Manually")),
       tags$hr(),
       conditionalPanel(
         condition = "input.upload_m == 'Google Drive'",
         textInput('gdrive_link', 'Google Drive Link:'),
         actionButton("import_button", "Import Data")
       ),
       conditionalPanel(
         condition = "input.upload_m == 'Manually'",
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

