library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE))

observe({
  if(!is.null(goop$combined_df)){
    filteredData <- reactive({
      df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
    })
    
    output$station <- renderUI({
      num_station <- unique(goop$combined_df$station)
      radioButtons('station', label = "Select station to graph", num_station)
    })
    
    output$variable_c <- renderUI({
      radioButtons("variable_choice",label = 'Select variable to graph',
                   choices = c("Low Range, µs/cm" = "Low_Range", "Full Range, µs/cm" = 'Full_Range', "Temp, C" = 'Temp_C'))
    })
      
    output$start_datetime_input <- renderUI({
      default_value <- as.character(goop$combined_df$Date_Time[1])
      textInput("start_datetime", "Enter start date and time (YYYY-MM-DD HH:MM:SS)", value = default_value)
    })
    
    output$end_datetime_input <- renderUI({
      default_value <- as.character(goop$combined_df$Date_Time[1])
      textInput("end_datetime", "End date and time", value = default_value)
    })
    
    output$main_plot <- renderUI({
      plotlyOutput("flag_plot")
    })
    
    output$flag_plot <- renderPlotly({
      plot_ly(data = filteredData(), type = 'scatter', x = ~Date_Time, y = as.formula(paste0('~', input$variable_choice)), 
              key = ~(paste0(as.character(Date_Time),"_",as.character(station))), color = ~as.character(station), opacity = 0.8) |>
        layout(dragmode = 'select') |>
        event_register(event = "plotly_selected")
    })
  }
  else{
    filteredData <- reactive({
      df_plot <- NULL
    })
    
    output$station <- renderUI({
      HTML("<label>Select station to graph<br></br></label>")
    })
    
    output$variable_c <- renderUI({
      HTML("<label>Select variable to graph<br></br></label>")
    })
    
    output$start_datetime_input <- renderUI({
      textInput("start_datetime", "Enter start date and time (YYYY-MM-DD HH:MM:SS)", value = "")
    })
    
    output$end_datetime_input <- renderUI({
       textInput("end_datetime", "End date and time", value = "")
    })
    
    output$main_plot <- renderUI({
    })
  }
})


selectedData <- reactive({
  df_plot <- goop$combined_df[goop$combined_df$station %in% input$station, ]
  event.selected.data <- event_data(event = "plotly_selected")
  df_chosen <- df_plot[paste0(df_plot$Date_Time,'_',df_plot$station) %in% event.selected.data$key,]
  return(df_chosen)
}) 

output$selected_data_table <- renderDT({
  datatable(selectedData(), options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE, paging = TRUE, info = FALSE, ordering = FALSE), rownames = FALSE)
})

observeEvent(input$flag_btn, {
  flag_name <- paste0(input$variable_choice, "_Flag")
  goop$combined_df[((goop$combined_df$id %in% selectedData()$id) & (goop$combined_df$station %in% selectedData()$station)), flag_name] <- input$flag_type  # Set the flag
})

#
# EXPORT STUFF
#