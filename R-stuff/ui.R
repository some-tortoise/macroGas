library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
library(shinyFiles)
library(shinyTime)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- navbarPage(strong("Salt Slugs"),
             tabPanel(strong('Home'),
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
                      
                      
             ),
             tabPanel('Visualize',
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
                                plotlyOutput('main_plot')
                              )
                            )
                          ),
                          fluidRow(
                            downloadButton('downloadBtn', 'Download'),
                            actionButton('upload_to_gdrive', 'Upload to Google Drive')
                          )
                      )),
             tabPanel("Upload",
                      useShinyjs(),
                      div(id = 'manual_container',
                      fluidRow(
                        sidebarLayout(
                          sidebarPanel(
                            fileInput("file1", "Choose CSV File",
                                      multiple = TRUE,
                                      accept = c("text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")),
                            tags$hr(),
                            checkboxInput("header", "Header", TRUE),
                            radioButtons("sep", "Separator",
                                         choices = c(Comma = ",",
                                                     Semicolon = ";",
                                                     Tab = "\t"),
                                         selected = ","),
                            tags$hr(),
                            radioButtons("row_and_col_select", "Choose which to edit",
                                         choices = c("rows",
                                                     "columns"),
                                         selected = "rows"),
                            actionButton('submit_delete', 'Delete selected'),
                            tags$hr(),
                            textInput('station_name','Enter station name'),
                            actionButton('viz_btn','Visualize')
                          ),
                          mainPanel(
                            DT::dataTableOutput('table1'),
                            DT::dataTableOutput("table2")
                          )
                        )
                      ))
                      
                      
                    )
             )
