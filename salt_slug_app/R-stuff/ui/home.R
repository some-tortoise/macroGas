div(class = 'home panel-container',
    div(class = 'home--boxes-container',
        div(
          class = "home--box-1",
          div(class = 'welcome-container',
              h1(class = 'title-text', "Welcome!"),
              div(class = 'home--bar1 style-bar')
              ),
          div(class = 'box-1-text-container',
              p("This app offers a user-friendly platform for uploading data from conservative tracer injections, visualizing conductivity breakthrough curves, conducting user-led quality assurance and quality control checks, and calculating key metrics such as discharge, time to half height, and groundwater exchange for a given experiment."), 
              p("Created in collaboration with the Bernhardt Lab at Duke University.")
              ),
          div(class = 'home--bar2 style-bar')
          ),
        div(
          class = "home--box-2",
          h1(class = 'title-text', "Resources"),
          p("For more information:"),
            p(tags$a(href = "http://dx.doi.org/10.1029/2011WR010942", "Covino et al. 2011. Stream-groundwater exchange and hydrologic turnover at the network scale.'")
          ),
          div(class = 'home--btn-container',
              actionButton('homeContinue', class='continue-btn', 'Continue')
          )
        )
  )
)
