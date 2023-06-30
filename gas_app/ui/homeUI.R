div(class = 'home-panel-container panel-container',
    fluidRow(
      h1("Home Page")),
    fluidRow(
      h3(HTML("<b>Get Data From Google Drive:</b>")),
      column(5,
        textInput('gdrive_link', "Enter Google Drive Link", NULL)),
      column(1,
        actionButton("import_button", icon("check")),
        bsTooltip("import_button", "Import file from the entered link", placement = "bottom", 
        trigger = "hover",options = list(container = "body"))
        )
      ),
    fluidRow(
            h5(HTML("<b>Select files:</b>")),
        column(width=5,
      selectInput("select", NULL, choices = NULL)
      ),
      column(width = 1,
             actionButton("delete", icon("trash")),
             bsTooltip("delete", "Delete the selected dataset", placement = "bottom", trigger = "hover",
                       options = list(container = "body"))
             )
      ),
    
    )