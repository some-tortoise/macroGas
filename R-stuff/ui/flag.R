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
      column(width= 5,
             radioButtons('station', label = 'Select station to view', c(1, 2, 3, 4, 5)),
             radioButtons("variable_choice",label = helpText('Select variable to graph'),
                          choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C')),
             textInput("start_datetime", "Enter Start Date and Time (YYYY-MM-DD HH:MM:SS)", value = "2023-01-01 00:00:00"),
             textInput("end_datetime", "End Date and Time", value = as.POSIXct("2023-01-10 23:59:59")),
             selectInput('flag_type', label = 'Select flag type', c('good', 'questionable', 'interesting', 'bad')),
             actionButton('flag_btn', label = 'Flag points'),
             actionButton('download', label = 'Download the flagged dataset')
      ),
      column(width= 7,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table')
      )
    )
)
