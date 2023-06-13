library(shiny)

ui <- fluidPage(
  titlePanel("Tabbed Example"),
  
  # Create the tabsetPanel
  tabsetPanel(
    # First tab
    tabPanel("Tab 1",
             h2("Content for Tab 1"),
             # Add any UI elements specific to Tab 1
    ),
    
    # Second tab
    tabPanel("Tab 2",
             h2("Content for Tab 2"),
             # Add any UI elements specific to Tab 2
    ),
    
    # Third tab
    tabPanel("Tab 3",
             h2("Content for Tab 3"),
             # Add any UI elements specific to Tab 3
    )
  )
)

server <- function(input, output) {
  # Server logic goes here
}

shinyApp(ui = ui, server = server)
