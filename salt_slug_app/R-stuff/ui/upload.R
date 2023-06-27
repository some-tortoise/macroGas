div(class = 'upload-panel-container panel-container',
    #column for sidebar options
    column(width = 3,
       h4("Instructions",
          bsButton("q1", label = "", icon = icon("question"), style = "info", size = "extra-small")),
       bsPopover(id = "q1", title = "",
                 content = paste0("The “Download File” button contains a CSV with an example breakthrough curve in the required formatting. Feel free to use this data to get familiar with using the app.<br><br>",
                                  "Match CSV files to the example formatting. If your data is missing certain fields, you can create the respective column and leave it blank (except for ’Station’). Column naming conventions must match. If each experiment station is saved as an individual CSV, you can either upload them one at a time (allowing us to validate formatting for each), or create one large CSV that identifies each station. Either way — there must be a station column! <em>Please only upload data from a single tracer injection experiment at a time!</em><br><br>",
                                  "<em>If uploading through Google Drive:</em> As with uploading manually, CSV formatting must match. In Google Drive, set the access under ‘Share’ in each CSV to ‘Anyone with the link’. Paste the drive link from the ‘Copy Link’ button within ‘Share’ into the app. Links must be to an individual CSV — links to folders will not work. Repeat the process for each station."),
                 placement = "right", 
                 trigger = "focus",
                 options = list(container = "body", html = TRUE)),
       h5("Data Template:"),
       downloadButton("downloadFile", "Download File"),
       br(),
       hr(),
       #two upload choices
       radioButtons("upload_m", "Import data from:", c("Manually", "Google Drive")),
       conditionalPanel(
         condition = "input.upload_m == 'Google Drive'",
         h5(HTML("<b>Link to CSV:</b>")),
         fluidRow(column(9,
                         textInput('gdrive_link', NULL)),
                  column(1,
                         actionButton("import_button", icon("check")),
                         bsTooltip("import_button", "Import file from the entered link", placement = "bottom", 
                                   trigger = "hover",options = list(container = "body")))),
         hr(),
         #textInput('gdrive_link', 'Google Drive Link:'),
         #actionButton("import_button", "Import Data")
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
       hr(),
       h5(HTML("<b>Select Files:</b>")),
       fluidRow(column(8,
                       selectInput("select", NULL, choices = NULL, width = "100%")),
                column(1,
                       actionButton("delete", icon("trash")),
                       bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
                                 options = list(container = "body")))),
       #selectInput("select", "Select Files", choices = NULL),
       #actionButton("delete", "Remove Selected Dataset"),
       hr(),
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

