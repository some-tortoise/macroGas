library(shiny)
library(DT)

ui <- fluidPage(
  titlePanel("Combine CSV Data"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("files", "Choose CSV Files",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
      ),
      actionButton("combine_button", "Combine Data")
    ),
    
    mainPanel(
      DTOutput("combined_table")
    )
  )
)

server <- function(input, output) {
  combined_data <- reactiveVal(NULL)
  
  observeEvent(input$files, {
    # Read the uploaded CSV files
    data <- lapply(input$files$datapath, read.csv)
    combined_data(data)
  })
  
  observeEvent(input$combine_button, {
    if (!is.null(combined_data())) {
      # Combine the data into one dataframe
      combined_df <- do.call(rbind, combined_data())
      combined_data(list(combined_df))
    }
  })
  
  output$combined_table <- renderDT({
    if (!is.null(combined_data())) {
      datatable(combined_data()[[1]], options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE))
    }
  })
}

shinyApp(ui = ui, server = server)
