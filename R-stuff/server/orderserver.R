library(shiny)
library(sortable)


orderserver <- function(input, output, session) {
  
  observeEvent(input$order, {
    ordered_labels <- c("Label 1", "Label 2", "Label 3")[input$order]
    updateTextInput(session, "input1", value = ordered_labels)
  })
}
