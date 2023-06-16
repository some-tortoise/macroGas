library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
library(sortable)



div(#class = 'order-panel-container panel-container',
    column(width = 5,
       rank_list(
         id = "sortable",
         items = c("Label 1", "Label 2", "Label 3"),
         inputId = "order"
                )
          ),
   column(
         width = 4,
         textInput("input1", "Assigned Value")
          )
          
     )
  
