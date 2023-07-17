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
    div(class = 'instructions-container', id = 'calcInstructionsBtn', '?'),
    div(id = 'calc-modal-container',
        div(id = 'calc-modal',
            div(class="modal-header",
                span(class="closeCalc close-modal","x"),
                h2("Instructions")
            ),
            p('some instructions')
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
