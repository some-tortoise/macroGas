tags$style(
  type = 'text/css',
  '.modal-dialog { width: fit-content !important; }'
)
div(class = 'flag-panel-container panel-container',
    fluidRow(
      column(width= 3,
             bsButton("q2", label = "Instructions", icon = icon("question"), style = "info", size = "extra-small"),
             bsPopover(id = "q2", title = "",
                       content = paste0("First, select a station you would like to view. Once selected, you can change the variable you are viewing. Then, click on a point or select multiple points on the plot to your right, then flag them using the buttons on your left"),
                       placement = "right", 
                       trigger = "focus",
                       options = list(container = "body", html = TRUE)),
             br(),
             br(),
             uiOutput("station"),
             radioButtons("variable_choice",label = 'Select variable to graph',
                          choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C')),
             uiOutput("start_datetime_input"),
             uiOutput("end_datetime_input"),
             selectInput('flag_type', label = 'Select Flag Type', c('good', 'questionable', 'interesting', 'bad')),
             actionButton('flag_btn', label = 'Flag points')
      ),
      column(width= 8,
             plotlyOutput('main_plot'),
             dataTableOutput('selected_data_table')
      )
    )
)
