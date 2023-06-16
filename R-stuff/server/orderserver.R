library(shiny)
library(sortable)


orderserver <- function(input, output, session) {
  
rank_list_swap <- rank_list(
    text = "Reorder your stations, earliest to latest",
    labels = c("Station A", "Station B", "Station C", "Station D", "Station E"),
    input_id = "rank_list_swap",
    options = sortable_options(swap = TRUE))
  
output$results_swap <- renderPrint(
  input$rank_list_swap) # This matches the input_id of the rank list
observe(
  update_rank_list(
    "rank_list_swap",
      session = session
      )
    ) %>%
      bindEvent(input$station_reorder)
}
