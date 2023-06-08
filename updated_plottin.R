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
                     actionButton('flag_btn', label = 'flag points')
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
                 downloadButton('downloadBtn', 'Download'),
                 actionButton('upload_to_gdrive', 'Upload to Google Drive')
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
    datatable(selectedData(), options = list(searching = FALSE, lengthChange = FALSE, paging = FALSE, info = FALSE, ordering = FALSE), rownames = FALSE)
  })
  
  observeEvent(input$flag_btn,{
    flag_name = paste0(input$variable_choice, "_Flag")
    data$df[((data$df$id %in% selectedData()$id) & (data$df$station %in% selectedData()$station)),flag_name] <- input$flag_type
  })
  
  
  
  #
  #DOWNLOAD STUFF
  #
  
  output$downloadBtn <- downloadHandler(
    filename = function() {
      # Set the filename of the downloaded file
      "my_file.csv"
    },
    content = function(file) {
      # Generate the content of the file
      # In this example, we create a simple CSV file with the Iris dataset
      write.csv(uploaded_data$data, file, row.names = FALSE)
      print('File has been \'downloaded\'')
    }
  )
  
  observeEvent(input$upload_to_gdrive, {
    name <- input$file1$name
    turn_file_to_csv(uploaded_data$data, name)
    upload_csv_file(uploaded_data$data, name)
    print('File has been \'uploaded\'')
  })
}

shinyApp(ui = ui, server = server)