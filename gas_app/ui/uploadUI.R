
div(class = 'upload-panel-container panel-container',
    #column for sidebar options
    column(width = 3,
              bsButton("q1", label = "Instructions", icon = icon("question"), style = "info", size = "extra-small"),
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
           br(),
           br(),
           downloadButton("downloadFile", "Download data format"),
           br(),
           #two upload choices
           radioButtons("upload_m", "Import data from:", c("Google Drive", "Manually")),
           conditionalPanel(
             condition = "input.upload_m == 'Google Drive'",
             h5(HTML("<b>G_Drive Link:</b>")),
             fluidRow(column(9,
                             textInput('gdrive_link', NULL)),
                      column(1,
                             actionButton("import_button", icon("check")),
                             bsTooltip("import_button", "Import file from the entered link", placement = "bottom", 
                                       trigger = "hover",options = list(container = "body"))))
             #textInput('gdrive_link', 'Google Drive Link:'),
             #actionButton("import_button", "Import Data")
           ),
           conditionalPanel(
             condition = "input.upload_m == 'Manually'",
             fileInput("upload", "Choose CSV file",
                       multiple = FALSE,
                       accept = c("text/csv",
                                  "text/comma-separated-values,text/plain",
                                  ".csv")
             )
           ),
           
           h5(HTML("<b>Select files:</b>")),
           fluidRow(column(8,
                           selectInput("select", NULL, choices = NULL, width = "100%")),
                    column(1,
                           actionButton("delete", icon("trash")),
                           bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
                                     options = list(container = "body")))),
           #selectInput("select", "Select Files", choices = NULL),
           #actionButton("delete", "Remove Selected Dataset"),
           br(),
           checkboxInput("Edit_upload", "Advanced editing", value = FALSE),
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
               p("Once you're happy with the uploaded files, click below to move on to QA/QC"),
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

