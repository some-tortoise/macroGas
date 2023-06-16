library(shiny)
library(sortable)


orderserver <- function(input, output, session) {
  rank_list_swap <- rank_list(
    labels = "station",
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
