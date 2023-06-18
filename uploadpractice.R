library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

######### UI############

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
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
        "csvs", "Choose CSV File",
        multiple = TRUE,
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
          "row_and_col_select", "Remove:",
          choices = c("Row(s)", "Column(s)"),
          selected = "rows"
        ),
        actionButton('submit_delete', 'Delete selected')
      )
    ),
    tags$hr(),
    # checkboxInput("header", "Header", FALSE),
    #radioButtons("sep", "Separator",
    #    choices = c(Comma = ",",
    #      Semicolon = ";" ,
    #     Tab = "\t"),
    # selected = ","),
    
     mainPanel(
      tags$hr(),
      column(
        width = 7,
        div(id = "upload_dt", DT::dataTableOutput('table1'))
      )
    )
  )
)

#div(
# actionButton('viz_btn','Visualize'))

##########SERVER CODE###############

server <- function(input, output) {
  
  uploadserver <- function(input, output, session)
  
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
  }) #instructions button function done#
  
  output$downloadFile <- downloadHandler(
      filename = "slugtemplate.csv",
      content = function(file) {
        write.csv(templateCSV, file, row.names = FALSE)
      }
    )
    
  observeEvent(input$csvs, {
    in_file <- NULL
    success <- FALSE
    tryCatch({
      in_file <- read.csv(input$csvs$datapath,
                          header = TRUE,
                          sep = ",")
    }, error = function(e){
      in_file <- NULL
    })
    
    if(!is.null(in_file)){
      names <- colnames(in_file)
      if("Station" %in% names){
        if(identical(sort(names), sort(c("Date_Time", "Station", "Low_Range", "Full_Range", "High_Range", "Temp_C"))))
          success <- TRUE
      }
      else{
        if(identical(sort(names), sort(c("Date_Time", "Low_Range", "Full_Range", "High_Range", "Temp_C"))))
          success <- TRUE
      }
    }
    
    if(success){
      showModal(modalDialog(
        h3("Your file is uploaded successfully!"),
        footer = tagList(
          modalButton('OK')
        )
      ))
      seq_csv <- seq(length(input$csvs$name))
      prev_num_files <- length(uploaded_data$data)
      
      uploaded_data$csv_names[[prev_num_files + 1]] <- input$csvs$name
      uploaded_data$data[[prev_num_files + 1]] <- as.data.frame(in_file)
      updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
    }
    else{
      showModal(modalDialog(
        h3("Your file upload failed! Please check the format of your file!"),
        footer = tagList(
          modalButton('OK')
        )
      ))
    }
  }) #read/validates the CSVs that are uploaded
  
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
  })
  
  observeEvent(input$Del,{
    index = uploaded_data$index
    uploaded_data$data <- uploaded_data$data[-index]
    uploaded_data$csv_names <- uploaded_data$csv_names[-index]
    updateSelectInput(session, 'select', choices = uploaded_data$csv_names)
  })
  
  output$table1 <- renderDT({
    if(length(uploaded_data$data)>0){
      targ <- switch(input$row_and_col_select,
                     'rows' = 'row',
                     'columns' = 'column')
      
      datatable(uploaded_data$data[[uploaded_data$index]], selection = list(target = targ),
                options = list(lengthChange = FALSE, ordering = FALSE, searching = FALSE, pageLength = 5)) 
    }
  })
  
  observeEvent(input$submit_delete, {
    val <- uploaded_data$index
    
    selected_rows <- as.integer(input$table1_rows_selected)
    selected_cols <- as.integer(input$table1_columns_selected)
    if (length(selected_rows) > 0) {
      uploaded_data$data[[val]] <- uploaded_data$data[[val]][-selected_rows, ]
    }
    if (length(selected_cols) > 0) {
      uploaded_data$data[[val]] <- uploaded_data$data[[val]][, -selected_cols, drop = FALSE]
    }
  })
  
  observeEvent(input$viz_btn, {
    # combine all elements of uploaded$data
    # add column with station names
    uploaded_data$combined_df <- '\'visualized\''
    print(uploaded_data$combined_df)
  })
}

shinyApp(ui = ui, server = server)

