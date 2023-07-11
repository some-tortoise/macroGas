div(class = 'home panel-container',
    div(class = 'home--boxes-container',
        div(
          class = "home--box-1",
          div(class = 'welcome-container',
              h1(class = 'title-text', "Welcome!"),
              div(class = 'home--bar1 style-bar')
              ),
          div(class = 'box-1-text-container',
              p("This app has been designed so users can easily take their conservative tracer/salt slug data and upload it from either Google Drive or locally, then flag points as they see fit, visualize their data, and calculate discharge and time to half height from their data."),
              p("This app was created for the Bernhardt Lab at Duke University.")
              ),
          div(class = 'home--bar2 style-bar')
          ),
        div(
          class = "home--box-2",
          h1(class = 'title-text', "Resources"),
          p("For more information:",
            tags$a(href = "http://dx.doi.org/10.1029/2011WR010942", "Covino et al. 2011. Stream-groundwater exchange and hydrologic turnover at the network scale.'"))
          )
        ),
    div(class = 'home--btn-container',
        actionButton('homeContinue', class='continue-btn', 'Continue')
        )
  )