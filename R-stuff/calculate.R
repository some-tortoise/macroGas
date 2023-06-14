library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

 div(
 column(width= 5,
        selectInput("station_picker", label = "Choose A Station", c(1, 2, 3, 4, 5)),
      numericInput("salt_mass", label = "Enter NaCl Mass Here", value = 1),
      textOutput("dischargeOutput", "Discharge")

  ),
 column(width = 7,
        plotOutput("dischargecalcplot"),
        dataTableOutput("dischargetable"))
)
 