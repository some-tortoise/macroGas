library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

div(class = 'visualize-panel-container panel-container',
  div(
    column(width = 5,
                 checkboxGroupInput('station_select', label = 'Select station(s)', c(1, 2, 3, 4, 5)),
                 radioButtons("variable_select",label = helpText('Select variable to graph'),
                              choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "High Range" = "High_Range", "Temp C" = 'Temp_C'))
                 ),
    column(width= 7,
              plotlyOutput('visualize-plot')
    )
  )
)
