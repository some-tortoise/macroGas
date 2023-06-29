div(class = 'home-panel-container panel-container',
  div(
    id = "box_1",
    style = "background-color: white ;
                width: 800px;
                height: 200px;
                padding: 10px;",
    h1("Welcome!"),
    p("This app has been designed so users can easily take their conservative tracer/salt slug data and upload it from either Google Drive or locally, then flag points as they see fit, visualize their data, and calculate discharge and time to half height from their data."),
    p("This app was created for the Bernhardt Lab at Duke University.")
  ),
  br(),
  br(),
  div(id = "box_2",
      style = " background-color: white ;
                width: 800px;
                height: 200px;
                padding: 10px;
                float: right",
      h2("Instructions and Resources"),
      p("For more information:",
        tags$a(href = "http://dx.doi.org/10.1029/2011WR010942", "Covino et al. 2011. Stream-groundwater exchange and hydrologic turnover at the network scale.'"))
      ),
  br(),
  br()
  )