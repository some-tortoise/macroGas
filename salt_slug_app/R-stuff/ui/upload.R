div(class = 'upload panel-container',
    div(class = 'upload--boxes-container',
        div(class = 'upload--box-1',
          p('Files that do not obey the data format will not be accepted. You can download the data format here.'),
          downloadButton("downloadFile", "Data format"), 
          div(class = 'upload--bar1 style-bar'),
          radioButtons('upload_m', 'How would you like to upload your data?', c('Manually', 'Through Google Drive ' = 'Google Drive')),
          conditionalPanel(
            condition = "input.upload_m == 'Google Drive'",
            strong('Link to CSV:'),
            fluidRow(column(9,
                            textInput('gdrive_link', NULL)),
                     column(1,
                            actionButton("import_button", icon("check")),
                            bsTooltip("import_button", "Import file from the entered link", placement = "bottom",
                                      trigger = "hover",options = list(container = "body")))),
            ),
          conditionalPanel(
            condition = "input.upload_m == 'Manually'",
            fileInput("upload", "Choose a CSV file",
                      multiple = FALSE,
                      accept = c("text/csv",
                                "text/comma-separated-values,text/plain",
                                ".csv")
                     )
             ),
          selectInput("select",'Your uploaded files', NULL, choices = NULL, width = "100%"),
          actionButton("delete", "Remove selected dataset")
          ),
        div(class = 'upload--box-2',
            div(class = 'upload--dt-container',
                DTOutput("contents")),
            div(id = "conditional", class = 'upload--continue-container',
                p('When you have uploaded all your files, press continue.'),
                actionButton('uploadContinue', class='continue-btn disabled', 'Continue'))
            )
        ),
    div(class = 'instructions-container', id = 'uploadInstructionsBtn', '?'),
    div(id = 'upload-modal-container',
      div(id = 'upload-modal',
          div(class="modal-header",
              h2("Instructions"),
              div(class="closeUpload close-modal","x")
          ),
          p('some instructions')
        )
    ),
    tags$script(HTML("
    document.getElementById('uploadInstructionsBtn').addEventListener('click', uploadInstructions);
    
    function uploadInstructions(){
      document.getElementById('upload-modal').style.display = 'block';
    }
    
    document.getElementsByClassName('closeUpload')[0].addEventListener('click', modalCloseUpload);
    
    function modalCloseUpload(){
    console.log('erf')
      document.getElementById('upload-modal').style.display = 'none';
    }
                     ")
                )
    )




# popoverTemplate <- 
#   '<div class="popover popover-lg" role="tooltip"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
# 
# div(class = 'upload panel-container',
#     tags$head(
#       tags$style(HTML(".popover.popover-lg {width: 500px; max-width: 500px;}"))
#     ),
#     #column for sidebar options
#     column(width = 3,
#                  bsButton("q1", label = "Instructions", icon = icon("question"), style = "info", size = "default"),
#        bsPopover(id = "q1", title = "",
#                  content = paste0("The “Download File” button contains a CSV with an example breakthrough curve in the required formatting. Feel free to use this data to get familiar with using the app.<br><br>",
#                                   "Match CSV files to the example formatting. If your data is missing certain fields, you can create the respective column and leave it blank (except for ’Station’). Column naming conventions must match. If each experiment station is saved as an individual CSV, you can either upload them one at a time (allowing us to validate formatting for each), or create one large CSV that identifies each station. Either way — there must be a station column! <em>Please only upload data from a single tracer injection experiment at a time!</em><br><br>",
#                                   "<em>If uploading through Google Drive:</em> As with uploading manually, CSV formatting must match. In Google Drive, set the access under ‘Share’ in each CSV to ‘Anyone with the link’. Paste the drive link from the ‘Copy Link’ button within ‘Share’ into the app. Links must be to an individual CSV — links to folders will not work. Repeat the process for each station."),
#                  placement = "right", 
#                  trigger = "focus",
#                  options = list(template = popoverTemplate)),
#        br(),
#        br(),
#        downloadButton("downloadFile", "Download data format"), 
#        br(),
#        br(),
#        #two upload choices
#        radioButtons("upload_m", "Import data from:", c("Manually", "Google Drive")),
#        conditionalPanel(
#          condition = "input.upload_m == 'Google Drive'",
#          h5(HTML("<b>Link to CSV:</b>")),
#          fluidRow(column(9,
#                          textInput('gdrive_link', NULL)),
#                   column(1,
#                          actionButton("import_button", icon("check")),
#                          bsTooltip("import_button", "Import file from the entered link", placement = "bottom", 
#                                    trigger = "hover",options = list(container = "body")))),
#        ),
#        conditionalPanel(
#          condition = "input.upload_m == 'Manually'",
#          fileInput("upload", "Choose CSV file",
#                  multiple = FALSE,
#                  accept = c("text/csv",
#                             "text/comma-separated-values,text/plain",
#                             ".csv")
#                  )
#          ),
#        h5(HTML("<b>Select files:</b>")),
#        fluidRow(column(8,
#                        selectInput("select", NULL, choices = NULL, width = "100%")),
#                 column(1,
#                        actionButton("delete", icon("trash")),
#                        bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
#                                  options = list(container = "body")))),
#        # selectInput("select", "Select Files", choices = NULL),
#        # actionButton("delete", "Remove Selected Dataset"),
#        # checkboxInput("Edit_upload", "Advanced editing", value = FALSE),
#        # conditionalPanel(
#        #   condition = "input.Edit_upload",
#        #   # numericInput('station_name','Enter station number', 0),
#        #   radioButtons("row_and_col_select", "Choose which to edit",
#        #                choices = c("rows",
#        #                            "columns"),
#        #                selected = "rows"),
#        #   actionButton('submit_delete', 'Delete selected')
#        #   )
#        ),
# 
#       #column for the output table
#      
#     column(width = 7,
#         div(
#           DTOutput("contents"),
#             div(
#                id = "conditional",
#                h5("When you're done uploading your data, click below to move on data trimming."),
#                actionButton("continue_button", "Continue")
#            )
#        )
#       )
# )
# 
