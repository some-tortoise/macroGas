library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

tags$style(
  type = 'text/css',
  '.modal-dialog { width: fit-content !important; }'
)
div(class = 'flag-panel-container panel-container',
    fluidRow(
      column(width= 3,
             HTML("<h5><b>Select station to view</b></h5>"),
             uiOutput("station"),
             radioButtons("variable_choice",label = helpText('Select variable to graph'),
                          choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C')),
             uiOutput("start_datetime_input"),
             uiOutput("end_datetime_input"),
             selectInput('flag_type', label = 'Select flag type', c('good', 'questionable', 'interesting', 'bad')),
             actionButton('flag_btn', label = 'Flag points')
      ),
      column(width= 8,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table')
      )
    )
)
