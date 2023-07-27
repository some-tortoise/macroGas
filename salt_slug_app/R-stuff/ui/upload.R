div(class = 'upload panel-container',
    div(class = 'upload--boxes-container',
        div(class = 'upload--box-1',
          p('Our application supports two types of data uploads: CSVs exported from HOBOware and CSVs that adhere to a specific format. 
            If you wish to upload \'clean\' CSVs, they should follow the provided data format that can be downloaded here:'),
          downloadButton("downloadFile", "Data format"), 
          div(class = 'upload--bar1 style-bar'),
          numericInput('station', 'Station:', 5),
          radioButtons('clean_or_hobo', 'What kind of data are you uploading?', c("HOBO", "Clean CSVs" = 'CLEAN')),
          
          #
          # if uploading HOBO data
          #
          
          conditionalPanel(
            condition = "input.clean_or_hobo == 'HOBO'",
            radioButtons('hobo_buttons', 'How would you like to upload your HOBO CSVs?', c('Manually' = 'hobo_manual' , 'Through Google Drive ' = 'hobo_gdrive'))
          ),
          
          # HOBO manually
          conditionalPanel(
            condition = "input.clean_or_hobo == 'HOBO' & input.hobo_buttons == 'hobo_manual'",
            fileInput("hoboupload", "Upload HOBO CSVs:",
                      multiple = FALSE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")
                      
          )
          ),
          
          # HOBO through gdrive
          conditionalPanel(
            condition = "input.clean_or_hobo == 'HOBO' & input.hobo_buttons == 'hobo_gdrive'",
            strong('Link to HOBO CSV:'),
            fluidRow(column(9,
                            textInput('gdrive_link', NULL)),
                     column(1,
                            actionButton("import_button", icon("check")),
                            bsTooltip("import_button", "Import file from the entered link", placement = "bottom",
                                      trigger = "hover",options = list(container = "body")))),
          ),
            

          # 
          # If uploading clean data
          #
          
          conditionalPanel(
            condition = "input.clean_or_hobo == 'CLEAN'",
            radioButtons('clean_buttons', 'How would you like to upload your clean CSVs?', c('Manually', 'Through Google Drive ' = 'gdrive')),
          ),
        
          # clean files through gdrive
          conditionalPanel(
            condition = "input.clean_buttons == 'gdrive' & input.clean_or_hobo != 'HOBO'",
            strong('Link to CSV:'),
            fluidRow(column(9,
                            textInput('gdrive_link', NULL)),
                     column(1,
                            actionButton("import_button", icon("check")),
                            bsTooltip("import_button", "Import file from the entered link", placement = "bottom",
                                      trigger = "hover",options = list(container = "body")))),
            ),
          
          # clean files through manual
          conditionalPanel(
            condition = "input.clean_buttons == 'Manually' & input.clean_or_hobo != 'HOBO'",
            fileInput("upload", "Upload CSV files:",
                      multiple = TRUE,
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
          tags$ul(
            tags$li('Please select whether you want to upload data manually (locally) or through a Google Drive link.'),
            tags$li('If you want to upload manually, select that option and then choose the file from your computer that you would like to upload.'), 
            tags$li('If uploading from Google Drive, paste the
            link to the folder your file is in when prompted.'),
            tags$li('All data must be a csv in the correct format, which you can find by downloading the format.'))
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


