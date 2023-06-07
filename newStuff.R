library(shiny)
library(plotly)
library(DT)

source(
  knitr::purl('updated_cleaning.R',
              output = tempfile(),
              quiet = TRUE))



ui <- fluidPage(
  sidebarPanel(
    selectInput('station', label = 'Select station', c('All',1, 2, 3, 4, 5)),
    radioButtons("variable_choice",label = helpText('Select variable to graph'),
                 choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C')),
    selectInput('flag_type_select', label = 'Select flag type', c('good', 'QuEstionable', 'inTeresting!', 'bAAd')),
    actionButton('flag_btn', label = 'flag points')
  ),
  mainPanel(
    plotlyOutput('myPlot'),
    dataTableOutput('selectedData')
  )
)

server <- function(input, output, session){
  output$myPlot = renderPlotly({
    df_plot <- combined_df[combined_df$station == as.numeric(input$station),]
    plot_ly(data = df_plot, x = ~Date_Time, y = as.formula(paste0('~',input$variable_choice)), key = ~id, color = ~Temp_C, source = "imgLink") %>%
      layout(xaxis = list(
        range = c(min(df_plot$Date_Time), max(df_plot$Date_Time)),  # Set the desired range
        type = "date"  # Specify the x-axis type as date
      ), dragmode = 'select')
    
  })
  
  output$selectedData <- renderDT({
    df_plot <- combined_df[combined_df$station == as.numeric(input$station),]
    event.click.data <- event_data(event = "plotly_click", source = "imgLink")
    event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
    df_chosen <- df_plot[((df_plot$id %in% event.click.data$key) | (df_plot$id %in% event.selected.data$key)),]
    datatable(df_chosen)
  })
  
  observeEvent(input$flag_btn,{
    flag_name = paste0(input$flag_type_select, "_Flag")
    combined_df[flag_name] <- 
    data$df[flag_name] <- ifelse((data$df$id %in% selectedData()[['id']] & 
                                    data$df$station==as.numeric(input$station)), 
                                 'bad', data$df[[flag_name]])
  })
}

shinyApp(ui, server)