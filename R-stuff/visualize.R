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
                 checkboxGroupInput('station', label = 'Select station', c(1, 2, 3, 4, 5)),
                 radioButtons("variable_choice",label = helpText('Select variable to graph'),
                              choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C'))
                 ),
    column(width= 7,
              plotlyOutput('main_plot'),
              dataTableOutput('selected_data_table')
    )
  )
)
