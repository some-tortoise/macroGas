library(shiny)
library(plotly) # for interactive graphs
library(sortable)

rank_list_swap <- rank_list(
  text = "Reorder your stations, earliest to latest",
  labels = c("Station A", "Station B", "Station C", "Station D", "Station E"),
  input_id = "rank_list_swap",
  options = sortable_options(swap = TRUE))


div(class = 'order-panel-container panel-container',
column(width = 5,
      rank_list_swap,
      actionButton("station_reorder", label = "Submit Station Reorder"))
)
  
