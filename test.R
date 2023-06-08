library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      fileInput("fileInput", "Select Files", multiple = TRUE),
      #actionButton("addFiles", "Add Files"),
      br(),
      verbatimTextOutput("fileList")
    ),
    mainPanel(
      # Output or other UI elements
    )
  )
)

server <- function(input, output, session) {
  # Create a reactive variable to store the selected files
  files <- reactiveValues(data = NULL)
  
  observeEvent(input$fileInput, {
    # Read the selected files
    selected_files <- input$fileInput$datapath
    
    # Add the selected files to the existing list
    files$data <- c(files$data, selected_files)
  })
  
  output$fileList <- renderPrint({
    # Render the list of selected files
    files$data
  })
}

shinyApp(ui = ui, server = server)
