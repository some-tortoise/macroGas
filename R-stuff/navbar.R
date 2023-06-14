library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

div(
  div(class = "tab",
      actionButton(inputId = 'defaultOpen',
                   class = "tablinks",
                   onclick = "openCity(event, 'London')",
                   label = "Upload"),
      actionButton(inputId = 'a',
                   class = "tablinks",
                   onclick = "openCity(event, 'Paris')",
                   label = "Flag"),
      actionButton(inputId = 'a',
                   class = "tablinks",
                   onclick = "openCity(event, 'Tokyo')",
                   label = "Calculate")
  ),
  div(inputId = 'a',
      id = "Londfon",
      class = "tabcontent",
      h3("London"),
      p("London is the capital city of England.")),
  div(inputId = 'a',
      id = "Parifs",
      class = "tabcontent",
      h3("Paris"),
      p("Paris is the capital city of England.")),
  div(inputId = 'a',
      id = "Tokyfo",
      class = "tabcontent",
      h3("Tokyo"),
      p("Tokyo is the capital city of England."))
)

