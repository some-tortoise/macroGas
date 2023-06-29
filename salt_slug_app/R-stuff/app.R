library(shiny) # for webpage creation
library(reactlog)
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime) 
library(sortable)
library(googledrive)
library(readr)
library(shinyBS)
library(tidyverse)
library(dplyr)
library(shinythemes)

reactlog_enable()
  
ui <- fluidPage(
  theme = shinytheme("flatly"),
  useShinyjs(),
  navbarPage(title = div(img(src = 'macrogas-logo.png', width = '60px')),id = "navbar",
                 tabPanel('Home',
                          source("ui/home.R")[1]),
                 tabPanel('Upload',
                          source("ui/upload.R")[1]),
                  tabPanel('Trim',
                      source("ui/trim.R")[1]),
                 tabPanel(title = 'QA/QC',
                          value = "flagpanel",
                          source("ui/flag.R")[1]),
                 tabPanel('Calculate',
                          source("ui/calculate.R")[1])
             ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  includeScript(path = "www/script.js"),
  
  tags$script(HTML("
    $(document).on('click', '.left-arrow', function(){
      var currentTab = $('#navbar .active > a').attr('data-value');
      var prevTab = $('#navbar a[data-value=\"' + currentTab + '\"]').parent().prev().find('a');
      if(prevTab.length > 0){
        $(prevTab).tab('show');
      }
    });

    $(document).on('click', '.right-arrow', function(){
      var currentTab = $('#navbar .active > a').attr('data-value');
      var nextTab = $('#navbar a[data-value=\"' + currentTab + '\"]').parent().next().find('a');
      if(nextTab.length > 0){
        $(nextTab).tab('show');
      }
    });
  ")),
  
  tags$style(HTML("
    .arrow {
      position: absolute;
      top: 85%;
      width: 40px;
      height: 40px;
      background-color: #ccc;
      border-radius: 50%;
      transform: translate(-50%, -50%);
      cursor: pointer;
      display: inline-flex;
      justify-content: center;
      align-items: center;
      font-size: 20px;
    }
    .left-arrow {
      left: 20px;
    }
  
    .right-arrow {
      right: 20px;
    }
  ")),
  
  tags$div(class = "arrow left-arrow", icon("chevron-left")),
  tags$div(class = "arrow right-arrow", icon("chevron-right"))
  )

server <-  function(input, output, session) {
  
  observeEvent(input$navbar, {
    currentTab <- input$navbar
    updateNavbarPage(session, "navbar", selected = currentTab)
  })
  
    goop <- reactiveValues()
    goop$combined_df <- combined_df
    
    # Call the server functions from the included files
    source("server/homeserver.R", local = TRUE)
    source("server/uploadserver.R", local = TRUE)
    source("server/trimserver.R", local = TRUE)
    source("server/flagserver.R", local = TRUE)
    source("server/calculateserver.R", local = TRUE)
}

shinyApp(ui = ui, server = server)
