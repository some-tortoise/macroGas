div(class = 'qaqc panel-container',
    div(class = 'qaqc--box1',
        uiOutput("station"),
        uiOutput("variable_c"),
        actionButton('downloadFlaggedDataset', 'Download Flagged Dataset')
        ),
    div(class = 'qaqc--box2',
        div(class = 'qaqc--graph-stuff',
            div(class = 'flag-container',
                h3('Flag Type'),
                selectInput('flag_type', label = '', c('NA', 'questionable', 'interesting', 'bad')),
                actionButton('flag_btn', label = 'Flag selected points')
                ),
            uiOutput('main_plot'),
            div(class = 'qaqc--continue-stuff',
                div(class = 'qaqc--continue-container',
                    p('When you have finished flagging, press continue'),
                    actionButton('qaqcContinue', class='continue-btn', 'Continue')
                    )
                )
            )
        ),
    div(class = 'instructions-container', id = 'flagInstructionsBtn', '?'),
    div(id = 'flag-modal-container',
        div(id = 'flag-modal',
            div(class="modal-header",
                span(class="closeFlag close-modal","x"),
                h2("Instructions")
            ),
            tags$ul(
              tags$li(HTML("<i>Please note that points flagged as 'bad' will be removed from the calculations on the next page.</i>")),
              tags$li('To flag points, make sure that the ‘box select’ option is selected in the top right of graph.'),
              tags$li('Once you have box selected the points you would like to flag, select from ‘interesting’, ‘bad’, or ‘questionable’ and select ‘Flag selected points’.'),
              tags$li('To remove flagged points, repeat the same process but set the flag type to ‘NA’.'),
              tags$li('For more precise flagging, utilize the zoom features in the top right of the graph before box selecting points.'))
        )
    ),
    tags$script(HTML("
    document.getElementById('flagInstructionsBtn').addEventListener('click', flagInstructions);
    
    function flagInstructions(){
      document.getElementById('flag-modal').style.display = 'block';
    }
    
    document.getElementsByClassName('closeFlag')[0].addEventListener('click', modalCloseFlag);
    
    function modalCloseFlag(){
      document.getElementById('flag-modal').style.display = 'none';
    }
                     ")
    )
    )
