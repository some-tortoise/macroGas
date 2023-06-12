library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- navbarPage(
  strong("Salt Slugs"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com"),
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Nunito+Sans&family=Roboto&display=swap")
    ),
  {tabPanel(strong('Home'),
                      titlePanel(strong("Salt Slugs")),
                      p(style="color:blue;", "Placeholder text welcoming science people to the salt slug visualization/computation app"),
                      br(),
                      br(),
                      hr(),
                      h4(strong("Resources:")),
                      p("For more information:",
                        tags$a(href = "http://dx.doi.org/10.1029/2011WR010942", "Covino et al. 2011. Stream-groundwater exchange and hydrologic turnover at the network scale.'")),
                      br(),
                      p('Template for salt slug data upload'),
                      p('Example salt slug data'),
                      div(id = 'upload_method',
                          tags$h1('How do you want to upload?'),
                          actionButton('gdrive_choice','Through Google Drive'),
                          actionButton('manual_choice','Manually')
                      )
                      
                      
             )},#HOME
  {tabPanel('Visualize',
            tags$style(
              type = 'text/css',
              '.modal-dialog { width: fit-content !important; }'
            ),
                      div(id = 'viz_container_div',
                          fluidRow(
                            column(width= 3,
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
                              column(width= 7,
                                plotlyOutput('main_plot')
                              ),
                            column(width=1,
                                   actionButton("do_math", "Do Math"))
                            )
                          ,
                          fluidRow(
                            column(width = 3, align = "center", offset = 5,
                            #downloadButton('downloadBtn', 'Download'),
                            #actionButton('upload_to_gdrive', 'Upload to Google Drive')
                          ))
                      ))}, #VISUALIZE
  {tabPanel("Upload",
             fluidRow(
               column(width = 3,
                   fileInput("csvs", "Choose CSV File",
                             multiple = TRUE,
                             accept = c("text/csv",
                                        "text/comma-separated-values,text/plain",
                                        ".csv")),
                   selectInput(inputId = 'select',
                               label = 'Select',
                               choices = c()),
                   tags$hr(),
                   numericInput('station_name','Enter station number', 0)
                 ),
                 column(width = 7,
                   div(id = "upload_dt", DT::dataTableOutput('table1'))
                 ),
               column(width = 2,
                            strong("Edit Data"),
                            tags$hr(),
                            checkboxInput("header", "Header", FALSE),
                            radioButtons("sep", "Separator",
                                         choices = c(Comma = ",",
                                                     Semicolon = ";",
                                                     Tab = "\t"),
                                         selected = ","),
                            radioButtons("row_and_col_select", "Choose which to edit",
                                         choices = c("rows",
                                                     "columns"),
                                         selected = "rows"),
                            actionButton('submit_delete', 'Delete selected'))
             
         ),
         fluidRow(
           actionButton('viz_btn','Visualize')
         )
)}, #UPLOAD
  tags$head(tags$script(src="script.js"))
)

