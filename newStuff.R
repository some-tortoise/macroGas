library(shiny)
library(plotly)
library(DT)

source(
  knitr::purl('updated_cleaning.R',
              output = tempfile(),
              quiet = TRUE))

df_plot <- combined_df[combined_df$station == 2,]

ui <- fluidPage(
  plotlyOutput('myPlot'),
  dataTableOutput('selectedData')
)

server <- function(input, output, session){
  output$myPlot = renderPlotly({
    plot_ly(data = df_plot, x = ~Date_Time, y = ~Low_Range, key = ~id, color = ~Temp_C, source = "imgLink") %>%
      layout(xaxis = list(
        range = c(min(df_plot$Date_Time), max(df_plot$Date_Time)),  # Set the desired range
        type = "date"  # Specify the x-axis type as date
      ), dragmode = 'select')
  })
  
  output$selectedData <- renderDT({
    event.click.data <- event_data(event = "plotly_click", source = "imgLink")
    event.selected.data <- event_data(event = "plotly_selected", source = "imgLink")
    df_chosen <- df_plot[((df_plot$id %in% event.click.data$key) | (df_plot$id %in% event.selected.data$key)),]
    datatable(df_chosen)
  })
}

shinyApp(ui, server)