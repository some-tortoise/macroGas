library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

div(class = 'flag-panel-container panel-container',
    fluidRow(
      column(width= 2,
             radioButtons('station', label = 'Select station', c(1, 2, 3, 4, 5)),
             radioButtons("variable_choice",label = helpText('Select variable to graph'),
                          choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
             selectInput('flag_type', label = 'Select flag type', c('good', 'QuEstionable', 'inTeresting!', 'bAd')),
             actionButton('flag_btn', label = 'flag points'),
             hr(),
             tags$style(
               type = 'text/css',
               '.modal-dialog { width: fit-content !important; }'
             ),
             actionButton('Download', label = 'Download the flagged dataset')
      ),
      column(width= 7,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table')
      ),
      column(width=2,
             dateInput('date1', 'Start of Slug Date:'),
             timeInput("time1", 'Start of Slug Time:'),
             actionButton("Add_date", "Add Time"))
    ),
    fluidRow(
      column(width = 3, align = "center", offset = 5,
             #downloadButton('downloadBtn', 'Download'),
             #actionButton('upload_to_gdrive', 'Upload to Google Drive')
    )),
    fluidRow(Position="right",
             )
)