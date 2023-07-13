library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyTime)

div(class = 'calculate panel-container',
    
    div(class = 'calculate--box1',
        div(class = 'calculate--sidebar',
            uiOutput("calc_station"),
            uiOutput("background_out"),
            numericInput("salt_mass", label = "NaCl Mass:", value = 1000)#,
            #checkboxInput('advancedEditing', 'Advanced Editing')
            ),
        div(class = 'calculate--graph-stuff',
            plotlyOutput("dischargecalcplot"),
            div(class = 'curr-station-deets',
                textOutput("dischargeOutput"),
                textOutput("halfheightOutput"))
            )
        ),
    div(class = 'calculate--box2',
        div(class = 'calculate--box3',
            div(class = 'general-stats-out',
                p(class = 'general-val-title', 'Groundwater Exchange: '),
                p(class = 'general-val', uiOutput('groundwaterOutput')),
                p(class = 'general-val-title', 'Average Discharge: '),
                p(class = 'general-val', uiOutput('avgDischargeOutput'))
                ),
            div(class = 'calculate--downloads-container',
                actionButton('downloadOutputTable', 'Download Output Table')
                )
            ),
        tableOutput("dischargetable")
        ),
    div(class = 'instructions-container', '?')
    )
# 
# div(class = 'calculate-panel-container panel-container',
#     fluidRow(class = 'calculate-top-container',
#           column(width = 5,
#                  class = 'calculate-input-container',
#                  uiOutput("calc_station"),
#                  uiOutput("start_time"),
#                  uiOutput("end_time"),
#                  uiOutput("background_out"),
#                  numericInput("salt_mass", label = "Enter NaCl Mass Here", value = 1000),
#                  hr(),
#                  h4("Current Station Calculations:"),
#                  textOutput("dischargeOutput"),
#                  textOutput("halfheightOutput"),
#                  actionButton('download', label = "",icon = icon("download"))
#                  ),
#           column(width = 5,
#                  class = 'calculate-graph-container',
#                  plotlyOutput("dischargecalcplot"),
#                  fluidRow(class = 'calculate-output-dt-container',
#                          tableOutput("dischargetable"))
#              )
#     )
# )

