library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
div(class = 'home-panel-container panel-container',
  div(
    id = "box_1",
    style = "background-color: white ;
                width: 800px;
                height: 200px;
                padding: 10px;",
    h1("Salt Slug App"),
    p("Placeholder text welcoming science people to the salt slug visualization/computation app")
  ),
  br(),
  br(),
  div(id = "box_2",
      style = " background-color: white ;
                width: 800px;
                height: 200px;
                padding: 10px;
                float: right",
      h2("Instructions and Resouces"),
      p("For more information:",
        tags$a(href = "http://dx.doi.org/10.1029/2011WR010942", "Covino et al. 2011. Stream-groundwater exchange and hydrologic turnover at the network scale.'"))
      ),
  br(),
  br()
  )