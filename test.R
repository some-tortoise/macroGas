library(shiny)
library(data.table)

ui <- fluidPage(
  titlePanel("Multiple file uploads"),
  sidebarLayout(
    sidebarPanel(
      fileInput("csvs",
                label="Upload CSVs here",
                multiple = TRUE)
    ),
    mainPanel(
      textOutput("count"),
      textOutput(("Listnames"))
      
    )
  )
)

server <- function(input, output) {
  mycsvs<-reactive({
    tmp <- lapply(input$csvs$datapath, fread)
    names(tmp) <- input$csvs$name
    tmp
    
  })
  output$count <- renderText(length(mycsvs()))
  output$Listnames <- renderText(names(mycsvs()))
}

shinyApp(ui = ui, server = server)
