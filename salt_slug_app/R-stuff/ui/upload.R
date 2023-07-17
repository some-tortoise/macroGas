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
                      multiple = TRUE,
                      accept = c("text/csv",
                                "text/comma-separated-values,text/plain",
                                ".csv")
                     )
             ),
          # fluidRow(column(8,
          #                 selectInput("select", NULL, choices = NULL, width = "100%")),
          #          column(1,
          #                 actionButton("delete", icon("trash")),
          #                 bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
          #                           options = list(container = "body")))),
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

# Previous Instructions
#The “Download File” button contains a CSV with an example breakthrough curve in the required formatting. Feel free to use this data to get familiar with using the app.<br><br>",
#                                   "Match CSV files to the example formatting. If your data is missing certain fields, you can create the respective column and leave it blank (except for ’Station’). Column naming conventions must match. If each experiment station is saved as an individual CSV, you can either upload them one at a time (allowing us to validate formatting for each), or create one large CSV that identifies each station. Either way — there must be a station column! <em>Please only upload data from a single tracer injection experiment at a time!</em><br><br>",
#                                   "<em>If uploading through Google Drive:</em> As with uploading manually, CSV formatting must match. In Google Drive, set the access under ‘Share’ in each CSV to ‘Anyone with the link’. Paste the drive link from the ‘Copy Link’ button within ‘Share’ into the app. Links must be to an individual CSV — links to folders will not work. Repeat the process for each station.


