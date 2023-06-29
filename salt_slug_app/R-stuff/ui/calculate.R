library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyTime)

div(class = 'calculate-panel-container panel-container',
    fluidRow(class = 'calculate-top-container',
          column(width = 5,
                 class = 'calculate-input-container',
                 selectInput("calc_station_picker", label = "Choose A Station", c(1, 2, 3, 4, 5)),
                 uiOutput("start_time"),
                 uiOutput("end_time"),
                 numericInput("background", label = "Enter background conductivity here", value = 100),
                 numericInput("salt_mass", label = "Enter NaCl Mass Here", value = 1000),
                 textOutput("dischargeOutput"),
                 actionButton('download', label = "",icon = icon("download"))
                 ),
          column(width = 5,
                 class = 'calculate-graph-container',
                 plotlyOutput("dischargecalcplot"),
                 fluidRow(class = 'calculate-output-dt-container',
                         dataTableOutput("dischargetable"))
             )
    )
)

