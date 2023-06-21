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
  titlePanel("Upload"),
  sidebarLayout(
    sidebarPanel(
      actionButton("uploadinstructions", "Instructions"),
      hr(),
      h5("Data Template:"),
      downloadButton("downloadFile", "Download File"),
      helpText("Download above data template for correct formatting."),
      #Two upload choices
      h5("Where would you like to import data from:"),
      actionButton('gdrive_choice', 'Through Google Drive'),
      actionButton('manual_choice', 'Manually'),
      tags$hr(),
      conditionalPanel(
        condition = "input.gdrive_choice",
        textInput('gdrive_link', 'Google Drive Link')
      ),
      conditionalPanel(
        condition = "input.manual_choice",
        fileInput(
          "upload", "Choose CSV File",
          multiple = FALSE,
          accept = c(
            "text/csv",
            "text/comma-separated-values,text/plain",
            ".csv"
          )
        )
      ),
      uiOutput("selectfiles"),
      actionButton("delete", "Remove selected dataset"),
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
        p("Once you're happy with the uploaded files, click below to move on to ordering."),
        actionButton("continue_button", "Continue")
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
      "Check if your file is CSV;
       Check if the data matches the format (See template by clicking 'Download File’);
       Choose how would you like to import file(s) - from Google Drive or from your local computer;
       The uploaded file will be displayed in the table below if it is correctly formatted;
       You can also futher edit your file here by using 'Advanced Editing';
       Go to 'Instruction' for help anytime!",
        easyClose = TRUE
    ))
  }) #instructions button 
  
  output$downloadFile <- downloadHandler( #data template download button
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
        "Uploaded CSV must have identical columns to the given template. If you do not have certain data, please leave that respective column blank."
      ))
    } else if (length(colnames(df)) > length(colnames(templateCSV))) {
      showModal(modalDialog(
        title = "Error",
        "Uploaded CSV has more columns than given template."
      ))
    } else {
      # Store uploaded data in the reactive uploaded_data value
      uploaded_data$data <- df
      dtRendered(TRUE) #set to TRUE as a condition for displaying continue actionbutton
      output$contents <- renderDT({
        datatable(df)
      })
    }

  ##naming conventions for stored data
  seq_csv <- seq_along(input$upload$name) # Generate a sequence of numbers
  prev_num_files <- length(uploaded_data$data)
  uploaded_data$csv_names <- c(uploaded_data$csv_names, input$upload$name)

  output$selectfiles <- renderUI({  
    if(is.null(input$upload)) {return()}
    selectInput("select", "Select Files", choices = uploaded_data$csv_names)
  })
  }) #all the code to upload, validate, display, and select user-uploaded CSVs

  observe({
    if(length(uploaded_data$csv_names) > 1){
      for(i in 1:length(uploaded_data$csv_names)){
        if(input$select == uploaded_data$csv_names[i]){
          uploaded_data$index <- i
        }
      } 
    }
    else
      uploaded_data$index <- 1
  }) #updates the uploaded_data$index based on how many CSVs are uploaded
  
  observeEvent(input$delete,{
    index = uploaded_data$index
    uploaded_data$data <- uploaded_data$data[-index]
    uploaded_data$csv_names <- uploaded_data$csv_names[-index]
    updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
  }) #deleting unwanted files
  
  observe({
    if (dtRendered()) { #dtRendered is a reactive value that's set to TRUE once df is displayed
      shinyjs::show("conditional")
    } else {
      shinyjs::hide("conditional")
    }
  }) #shinyJS code to to show/hide actionbutton to continue on to ordering
  
}

shinyApp(ui = ui, server = server)