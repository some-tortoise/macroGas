library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
library(shinyBS)

  div(class = 'upload-panel-container panel-container',
  column(width = 3,
         actionButton("uploadinstruction",label = "?"),
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
         h4("Data Template:"),
         downloadButton("downloadFile", "Download File"),
         hr(),
         fileInput("csvs", label = "Choose CSV File",
                   multiple = FALSE,
                   accept = c("text/csv",
                              "text/comma-separated-values,text/plain",
                              ".csv")),
         selectInput(inputId = 'select',
                     label = 'Select',
                     choices = c()),
         actionButton("Del", "Delete the current dataset"),
         tags$hr(),
         checkboxInput("Edit_upload", "Advanced Editing", value = FALSE),
         conditionalPanel(
           condition = "input.Edit_upload",
           # numericInput('station_name','Enter station number', 0),
           radioButtons("row_and_col_select", "Choose which to edit",
                        choices = c("rows",
                                    "columns"),
                        selected = "rows"),
           actionButton('submit_delete', 'Delete selected'))
         ),
         tags$hr(),
         # checkboxInput("header", "Header", FALSE),
         #radioButtons("sep", "Separator",
         #    choices = c(Comma = ",",
         #      Semicolon = ";" ,
         #     Tab = "\t"),
         # selected = ","),
  
  column(width = 7,
         div(id = "upload_dt", DT::dataTableOutput('table1'))
         )#,
  #,
#div(
 # actionButton('viz_btn','Visualize'))
)

