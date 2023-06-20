library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
library(htmlwidgets)
library(shinyFiles)
library(shinyTime)

######### UI############

ui <- fluidPage(
  useShinyjs(),
  # navbar 
  sidebarLayout(
    sidebarPanel(
      "", width = 4,
      actionButton("uploadinstructions", "Instructions"),
      hr(),
      h4("Data Template:"),
      downloadButton("downloadFile", "Download File"),
      br(),
      hr(),
      fileInput(
        "upload", "Choose CSV File",
        multiple = FALSE,
        accept = c(
          "text/csv",
          "text/comma-separated-values,text/plain",
          ".csv"
        )
      ),
      selectInput(
        inputId = 'select',
        label = 'Select',
        choices = c()
      ),
      actionButton("Del", "Delete the current dataset"),
      tags$hr(),
      checkboxInput("Edit_upload", "Advanced Editing", value = FALSE),
      conditionalPanel(
        condition = "input.Edit_upload",
        # numericInput('station_name','Enter station number', 0),
        radioButtons(
          "row_select", "Remove:",
          choices = c("Row(s)", "Column(s)"),
          selected = "rows"
        ),
        actionButton('submit_delete', 'Delete selected')
      )
    ),
    mainPanel(
      DTOutput("contents"),
      #conditional panel that should only show if the data frame has been rendered
      mainPanel(id = "conditional",
        h4("Let's move on to ordering."),
        actionButton("moveon_button", "Move on")
      )
    )
  )
)
  


###########server#############

server <- function(input, output, session){
  
  templateCSV <- data.frame(
    "Date_Time" = c("05/25/23 12:00:00 PM", "05/25/23 12:00:05 PM", "05/25/23 12:00:10 PM"),
    "Station" = c(1, 2, 3),
    "Low_Range" = c(1, 2, 3),
    "Full_Range" = c(1, 2, 3),
    "High_Range" = c(1, 2, 3),
    "Temp_C" = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
  
  dtRendered <- reactiveVal(FALSE)
  
  uploaded_data <- reactiveValues(csv_names = NULL, 
                                  data = NULL,
                                  index = 1,
                                  station_names = NULL,
                                  combined_df = NULL)
  
  observeEvent(input$uploadinstructions, { 
    showModal(modalDialog(
      title = "Instructions",
      "Upload page instructions placeholder text..."
    ))
  }) #instructions button 
  
  output$downloadFile <- downloadHandler(  
    filename = "slugtemplate.csv",
    content = function(file) {
      write.csv(templateCSV, file, row.names = FALSE)
    }
  )
  
  observeEvent(input$upload, {
    req(input$upload)
    df <- read.csv(input$upload$datapath)
    
    if (!identical(colnames(df), colnames(templateCSV))) {
      showModal(modalDialog(
        title = "Error",
        "Uploaded CSV must have identical columns to the given template. If you do not have certain data such as full range conductivity measurements, please leave that respective column blank."
      ))
    } else if (length(colnames(df)) > length(colnames(templateCSV))) {
      showModal(modalDialog(
        title = "Error",
        "Uploaded CSV has more columns than given template."
      ))
    } else {
      # Store uploaded data in the reactive uploaded_data value
      uploaded_data$data <- df
      dtRendered(TRUE)
      output$contents <- renderDT({
        datatable(df)
      })
    }
  })
  
  observe({
    if (dtRendered()) {
      shinyjs::show("conditional")
    } else {
      shinyjs::hide("conditional")
    }
  })  
  
  
}
  
shinyApp(ui = ui, server = server)
