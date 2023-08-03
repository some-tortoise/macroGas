library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyTime)

div(class = 'calculate panel-container',
    
    div(class = 'calculate--box1',
        div(class = 'calculate--sidebar',
            uiOutput("calc_station"),
            uiOutput("background_out"),
            uiOutput("salt_out"),
            uiOutput("distance_out"),
            uiOutput("width_out"),
            checkboxInput("excludeflags", "Exclude 'bad' flags", value = FALSE, width = NULL)
            
            ),
        div(class = 'calculate--graph-stuff',
            plotlyOutput("dischargecalcplot"),
            div(class = 'curr-station-deets',
                textOutput("dischargeOutput"),
                textOutput("halfheightOutput"),
                )
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
    div(class = 'instructions-container', id = 'calcInstructionsBtn', '?'),
    div(id = 'calc-modal-container',
        div(id = 'calc-modal',
            div(class="modal-header",
                span(class="closeCalc close-modal","x"),
                h2("Instructions")
            ),
            tags$ul(
              tags$li('Manually enter the background conductivity, found by looking at the graph and seeing the baseline of conductivity before the curve.'),
              tags$li("Enter the mass of salt used in your salt slug."),
              tags$li("Double click to zoom out of the graph and hover over a point to see its values."),
              tags$li("Do this process in full for each station. When finished with all stations, the average discharge and groundwater exchange across all sites will be displayed." ))
        )
    ),
    tags$script(HTML("
    document.getElementById('calcInstructionsBtn').addEventListener('click', calcInstructions);
    
    function calcInstructions(){
      document.getElementById('calc-modal').style.display = 'block';
    }
    
    document.getElementsByClassName('closeCalc')[0].addEventListener('click', modalCloseCalc);
    
    function modalCloseCalc(){
      document.getElementById('calc-modal').style.display = 'none';
    }
                     ")
    )
    )
