#
# PACKAGES
#

require(shiny) # for webpage creation
require(reactlog)
require(plotly) # for interactive graphs
require(DT) # for datatables
require(htmlwidgets)
require(shinyjs)
require(shinyFiles)
require(shinyTime) 
require(sortable)
require(readr)
require(shinyBS)
require(tidyverse)
require(dplyr)
require(shinythemes)
require(lubridate)
require(knitr)
require(kableExtra)
require(reshape2)
require(ggplot2)

combined_df <- NULL

js_code <- HTML("shinyjs.enableUpload = function() {
               document.getElementById('uploadContinue').classList.remove('disabled')
           }")

ui <- fluidPage(class = 'body-container',
  theme = shinytheme("flatly"),
  tags$head(
    HTML(
      '<link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Inknut+Antiqua:wght@400;500;700;800;900&family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">'
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  useShinyjs(),
  extendShinyjs(text = js_code, functions = "enableUpload"),
  navbarPage(title = '', id = "navbar",
                 tabPanel('Home',
                          source("ui/home.R")[1]),
                 tabPanel('Upload',
                          source("ui/upload.R")[1]),
                  tabPanel('Trim',
                          value = "trimpanel",
                          source("ui/trim.R")[1]),
                 tabPanel(title = 'QA/QC',
                          value = "flagpanel",
                          source("ui/flag.R")[1]),
                 tabPanel('Calculate',
                          source("ui/calculate.R")[1])
             ),

    tags$script(HTML("
    $(document).on('click', '.continue-btn', function(){
      if(this.classList.contains('disabled')) return;
      var currentTab = $('#navbar .active > a').attr('data-value');
      var nextTab = $('#navbar a[data-value=\"' + currentTab + '\"]').parent().next().find('a');
      if(nextTab.length > 0){
        $(nextTab).tab('show');
      }
    });
  ")),
  )
 
server <-  function(input, output, session) {
  
  observeEvent(input$navbar, {
    currentTab <- input$navbar
    updateNavbarPage(session, "navbar", selected = currentTab)
  })
  
    goop <- reactiveValues()
    goop$combined_df <- combined_df
    
    # Call the server functions from the included files
    source("server/uploadserver.R", local = TRUE)
    source("server/trimserver.R", local = TRUE)
    source("server/flagserver.R", local = TRUE)
    source("server/calculateserver.R", local = TRUE)
}

shinyApp(ui = ui, server = server)

