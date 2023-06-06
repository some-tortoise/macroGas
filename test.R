library(shiny)
library(shinyFiles)

ui <- fluidPage(
  shinyDirButton("folderBtn", "Select Folder", title = "Choose Download Location"),
  downloadButton("downloadBtn", "Download File")
)

server <- function(input, output, session) {
  shinyFileChoose(input, "folderBtn", roots = c(home = '~'))
  
  output$downloadBtn <- downloadHandler(
    filename = function() {
      # Set the filename of the downloaded file
      "my_file.csv"
    },
    content = function(file) {
      # Generate the content of the file
      # In this example, we create a simple CSV file with the Iris dataset
      write.csv(iris, file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)
