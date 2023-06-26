library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)

source(knitr::purl("updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- navbarPage('',
                 tags$style(
                   type = 'text/css',
                   '.modal-dialog { width: fit-content !important; }'
                 ),
  tabPanel("Upload",
           useShinyjs(),
           
           div(id = 'viz_container_div',
               fluidRow(
                 sidebarLayout(
                   sidebarPanel(
                     checkboxGroupInput('station', label = 'Select station', c(1, 2, 3, 4, 5)),
                     radioButtons("variable_choice",label = helpText('Select variable to graph'),
                                  choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
                     dateInput('date1', 'Start of Slug Date:'),
                     timeInput("time1", 'Start of Slug Time:'),
                     selectInput('flag_type', label = 'Select flag type', c('good', 'QuEstionable', 'inTeresting!', 'bAd')),
                     actionButton('flag_btn', label = 'flag points'),
                     hr(),
                     actionButton('Download', label = 'Download the flagged dataset')
                   ),
                   mainPanel(
                     tabsetPanel(type = 'tabs',
                                 tabPanel('plot', 
                                          plotlyOutput('main_plot'),
                                          dataTableOutput('selected_data_table')
                                 )
                     )
                   )
                 )
               ),
               fluidRow(
                 #downloadButton('downloadBtn', 'Download'),
                 #actionButton('upload_to_gdrive', 'Upload to Google Drive')
               )
           )
           
  )
)

server <- function(input, output){
  #
  # VISUALIZATION STUFF
  #
  
  data <- reactiveValues(df = combined_df)
  
  
  selectedData <- reactive({
    df_plot <- data$df[data$df$station %in% input$station,]
    event.click.data <- event_data(event = "plotly_click", source = "imgLink")
    event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
    df_chosen <- df_plot[((paste0(df_plot$id,'_',df_plot$station) %in% event.click.data$key) | 
                            (paste0(df_plot$id,'_',df_plot$station) %in% event.selected.data$key)),]
    return(df_chosen)
  })
  
  
  
  output$main_plot = renderPlotly({
    df_plot <- data$df[data$df$station %in% input$station,]
    color_mapping <- c("1" = "red", "2" = "blue", "3" = "green", "4" = "purple", "5" = "black")
    
    # Get the minimum and maximum values of Date_Time vector
    if(length(df_plot$Date_Time) > 0){
      min_date <- min(df_plot$Date_Time)
      max_date <- max(df_plot$Date_Time)
    }else{
      min_date <- Sys.Date()
      max_date <- Sys.Date()
    }
    
    plot_ly(data = df_plot, type = 'scatter', mode = 'markers', x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~(paste0(id,"_",station)), color = ~as.character(station), colors = ~color_mapping, opacity = 0.5, source = "imgLink") %>%
      layout(xaxis = list(
        range = c(min_date, max_date),  # Set the desired range
        type = "date"  # Specify the x-axis type as date
      ), dragmode = 'select')
    
  })
  
  output$selected_data_table <- renderDT({
    datatable(selectedData(), options = list(pageLength = 5, searching = FALSE, info = FALSE, ordering = FALSE), rownames = FALSE)
  })
  
  observeEvent(input$flag_btn,{
    flag_name = paste0(input$variable_choice, "_Flag")
    data$df[((data$df$id %in% selectedData()$id) & (data$df$station %in% selectedData()$station)),flag_name] <- input$flag_type
  })
  
  
  
  #
  #DOWNLOAD STUFF
  #
  
  observeEvent(input$Download, {
    showModal(modalDialog(
      title = 'Are you sure you want to download the dataset below:',
      dataTableOutput('finalDT'),
      downloadButton('downloadBtn', 'Download'),
      actionButton('upload_to_gdrive', 'Upload to Google Drive'),
      easyClose = FALSE,
      footer = tagList(
        modalButton("Close")
      )
    ))
  })
  
  output$finalDT <- renderDT({
    datatable(data$df, options = list(pageLength = 20))
  })
  
  output$downloadBtn <- downloadHandler(
    filename = function() {
      # Set the filename of the downloaded file
      "flagged_data.csv"
    },
    content = function(file) {
      # Generate the content of the file
      write.csv(data$df, file, row.names = FALSE)
    }
  )
  
  observeEvent(input$upload_to_gdrive, {
    name <- 'flagged_data.csv'
    showModal(modalDialog(
      textInput('drivePath', 'Please enter the path of the folder in your googledrive:'),
      actionButton('path_ok', 'OK')
    ))
  })
  
  observeEvent(input$path_ok,{
    turn_file_to_csv(data$df, name)
    upload_csv_file(data$df, name, input$drivePath)
    if(paste0('processed_', name) %in% (drive_ls(input$drivePath)[['name']])){
      showModal(modalDialog(
        h3('File has been uploaded successfully!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
    else{
      showModal(modalDialog(
        h3('File upload failed!'),
        easyClose = FALSE,
        footer = tagList(
          modalButton('Back')
        )
      ))
    }
  })
}

shinyApp(ui = ui, server = server)