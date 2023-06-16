library(shiny)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
library(sortable)

rank_list_swap <- rank_list(
  text = "Reorder your stations",
  labels = c("station", "2"),
  input_id = "rank_list_swap",
  options = sortable_options(swap = TRUE))


  div(#class = 'order-panel-container panel-container',
column(width = 5,
      rank_list_swap,
      actionButton("station_reorder", label = "Submit Station Reorder")),
column(width = 9
       )
          
         )
  
