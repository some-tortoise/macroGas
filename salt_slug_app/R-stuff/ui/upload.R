div(class = 'upload panel-container',
    div(class = 'upload--boxes-container',
        div(class = 'upload--box-1',
          p('Our application supports two types of data uploads, CSVs exported from HOBOware and CSVs that adhere to a specific format. 
            If you wish to upload \'clean\' CSVs, they should follow the provided data format that can be downloaded here:'),
          downloadButton("downloadFile", "Data format"), 
          div(class = 'upload--bar1 style-bar'),
          radioButtons('clean_or_hobo', 'What kind of data are you uploading?', c("HOBO", "Clean CSVs" = 'CLEAN')),

          # Conditional panel for uploading HOBO files
          conditionalPanel(
            condition = "input.clean_or_hobo == 'HOBO'",
            actionButton("hobobutton", "Upload Hobo Files", icon = NULL),
            br(),
            br()
          ),
  
          # Conditional panel for uploading clean files
          conditionalPanel(
            condition = "input.clean_or_hobo == 'CLEAN'",
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
              div(class="closeUpload close-modal", "x")
          ),
          tags$ul(
            tags$li("You can upload either CSVs from the HOBOware software or CSVs that follow our data format ('clean CSVs')."),
            tags$li("If you upload HOBO data, it will be cleaned to meet the app's standards before continuing."),
            tags$li("When uploading HOBO data, make sure to enter the correct station number before uploading each new file."),
            tags$li("Clean CSVs can be uploaded as individual files for each station or as one CSV file that identifies each station correctly within the station column."),
            tags$li("If you accidentally upload the wrong file, simply select it within the 'Your uploaded files' dropdown and choose 'Remove selected dataset'."),
            tags$li("This app is designed to handle data from one experiment at a time. Please avoid uploading data from multiple salt slug experiments.")
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
)

# Previous Instructions
#The “Download File” button contains a CSV with an example breakthrough curve in the required formatting. Feel free to use this data to get familiar with using the app.<br><br>",
#                                   "Match CSV files to the example formatting. If your data is missing certain fields, you can create the respective column and leave it blank (except for ’Station’). Column naming conventions must match. If each experiment station is saved as an individual CSV, you can either upload them one at a time (allowing us to validate formatting for each), or create one large CSV that identifies each station. Either way — there must be a station column! <em>Please only upload data from a single tracer injection experiment at a time!</em><br><br>",
#                                   "<em>If uploading through Google Drive:</em> As with uploading manually, CSV formatting must match. In Google Drive, set the access under ‘Share’ in each CSV to ‘Anyone with the link’. Paste the drive link from the ‘Copy Link’ button within ‘Share’ into the app. Links must be to an individual CSV — links to folders will not work. Repeat the process for each station.


