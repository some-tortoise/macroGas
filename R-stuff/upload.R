library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

div(
  div(
  column(width = 3,
         fileInput("csvs", "Choose CSV File",
                   multiple = TRUE,
                   accept = c("text/csv",
                              "text/comma-separated-values,text/plain",
                              ".csv")),
         selectInput(inputId = 'select',
                     label = 'Select',
                     choices = c()),
         tags$hr(),
         numericInput('station_name','Enter station number', 0)
  ),
  column(width = 7,
         div(id = "upload_dt", DT::dataTableOutput('table1'))
  ),
  column(width = 2,
         strong("Edit Data"),
         tags$hr(),
         checkboxInput("header", "Header", FALSE),
         radioButtons("sep", "Separator",
                      choices = c(Comma = ",",
                                  Semicolon = ";",
                                  Tab = "\t"),
                      selected = ","),
         radioButtons("row_and_col_select", "Choose which to edit",
                      choices = c("rows",
                                  "columns"),
                      selected = "rows"),
         actionButton('submit_delete', 'Delete selected'))
  
),
div(
  actionButton('viz_btn','Visualize')
))

