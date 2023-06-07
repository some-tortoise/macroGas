library(shiny)
library(plotly)
library(DT)

source(
  knitr::purl('updated_cleaning.R',
              output = tempfile(),
              quiet = TRUE))

ui <- fluidPage(
  sidebarPanel(
    checkboxGroupInput('station', label = 'Select station', c(1, 2, 3, 4, 5)),
    radioButtons("variable_choice",label = helpText('Select variable to graph'),
                 choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
    selectInput('flag_type', label = 'Select flag type', c('good', 'QuEstionable', 'inTeresting!', 'bAd')),
    actionButton('flag_btn', label = 'flag points')
  ),
  mainPanel(
    plotlyOutput('main_plot'),
    dataTableOutput('selected_data_table')
  )
)

server <- function(input, output, session){
  
  data <- reactiveValues(df = combined_df)
  
  selectedData <- reactive({
    df_plot <- data$df[data$df$station == as.numeric(input$station),]
    event.click.data <- event_data(event = "plotly_click", source = "imgLink")
    event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
    df_chosen <- df_plot[((df_plot$id %in% event.click.data$key) | (df_plot$id %in% event.selected.data$key)),]
    return(df_chosen)
  })
  
  output$main_plot = renderPlotly({
    df_plot <- data$df[data$df$station == input$station,]
    plot_ly(data = df_plot, x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~id, color = ~as.character(station), source = "imgLink") %>%
      layout(xaxis = list(
        range = c(min(df_plot$Date_Time), max(df_plot$Date_Time)),  # Set the desired range
        type = "date"  # Specify the x-axis type as date
      ), dragmode = 'select')
    
  })
  
  output$selected_data_table <- renderDT(selectedData())
  
  observeEvent(input$flag_btn,{
    flag_name = paste0(input$variable_choice, "_Flag")
    data$df[((data$df$id %in% selectedData()$id) & (data$df$station %in% selectedData()$station)),flag_name] <- input$flag_type
  })
  
}

shinyApp(ui, server)