div(class = 'home-panel-container panel-container',
    fluidRow(
      h1("Home Page")),
    fluidRow(
      actionButton("get_data", label = "Get Data from Google Drive")
      ),
    fluidRow(
            h5(HTML("<b>Select files:</b>")),
        column(width=7,
      selectInput("select", NULL, choices = NULL, width = "100%")
      ),
      column(width = 1,
             actionButton("delete", icon("trash")),
             bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
                       options = list(container = "body"))
             )
      )
)