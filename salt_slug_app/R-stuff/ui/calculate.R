library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyTime)

div(class = 'calculate-panel-container panel-container',
    fluidRow(class = 'calculate-top-container',
          column(width = 5,
                 class = 'calculate-input-container',
                 uiOutput("calc_station"),
                 uiOutput("start_time"),
                 uiOutput("end_time"),
                 uiOutput("background_out"),
                 numericInput("salt_mass", label = "Enter NaCl Mass Here", value = 1000),
                 textOutput("dischargeOutput"),
                 textOutput("halfheightOutput"),
                 actionButton('download', label = "",icon = icon("download"))
                 ),
          column(width = 5,
                 class = 'calculate-graph-container',
                 plotlyOutput("dischargecalcplot"),
                 fluidRow(class = 'calculate-output-dt-container',
                         DTOutput("dischargetable"))
             )
    )
)

