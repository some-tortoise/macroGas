library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables

div(class = 'calculate-panel-container panel-container',
    fluidRow(class = 'calculate-top-container',
          column(width = 5,
                 class = 'calculate-input-container',
                 selectInput("station_picker", label = "Choose A Station", c(1, 2, 3, 4, 5)),
                 numericInput("salt_mass", label = "Enter NaCl Mass Here", value = 1)
                 #textOutput("dischargeOutput")
                 ),
          column(width = 5,
                 class = 'calculate-graph-container',
                 plotOutput("dischargecalcplot"),
                 )
          ),
    fluidRow(class = 'calculate-output-dt-container',
             dataTableOutput("dischargetable")
             )
    
)

