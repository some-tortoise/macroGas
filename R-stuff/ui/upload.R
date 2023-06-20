library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

  div(class = 'upload-panel-container panel-container',
  column(width = 3,
         actionButton("uploadinstruction", "?"),
         hr(),
         h4("Data Template:"),
         downloadButton("downloadFile", "Download File"),
         hr(),
         fileInput("csvs", "Choose CSV File",
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

