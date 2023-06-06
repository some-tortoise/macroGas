library(shiny) # for webpage creation
library(plotly) # for interactive graphs
library(DT) # for datatables
library(htmlwidgets)
library(shinyjs)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

ui <- fluidPage(
  navbarPage("Salt Slugs",
             tabPanel("Visualize",
                      useShinyjs(),
                      titlePanel("Salt Slug Visualizations"),
                      sidebarLayout(
                        sidebarPanel(
                          selectInput('station', label = 'Select station', c(1, 2, 3, 4, 5)),
                          radioButtons("variable_choice",label = helpText('Select variable to graph'),
                                       choices = c("Low Range" = "Low_Range", "Full Range" = 'Full_Range', "Temp C" = 'Temp_C'))
                        ),
                        mainPanel(
                          tabsetPanel(type = 'tabs',
                                      tabPanel('plot', 
                                               plotlyOutput("plotOutput"),
                                               dataTableOutput('clicked')
                                      ),
                                      tabPanel('table', 
                                               dataTableOutput('df')
                                      )
                          )
                        )
                      )),
             tabPanel("Upload",
                      sidebarLayout(
                        
                        # Sidebar panel for inputs ----
                        sidebarPanel(
                          
                          # Input: Select a file ----
                          fileInput("file1", "Choose CSV File",
                                    multiple = TRUE,
                                    accept = c("text/csv",
                                               "text/comma-separated-values,text/plain",
                                               ".csv")),
                          
                          # Horizontal line ----
                          tags$hr(),
                          
                          # Input: Checkbox if file has header ----
                          checkboxInput("header", "Header", TRUE),
                          
                          # Input: Select separator ----
                          radioButtons("sep", "Separator",
                                       choices = c(Comma = ",",
                                                   Semicolon = ";",
                                                   Tab = "\t"),
                                       selected = ","),
                          
                          # Input: Select number of rows to display ----
                          
                          tags$hr(),
                          
                          radioButtons("row_and_col_select", "Choose which to edit",
                                       choices = c("rows",
                                                   "columns"),
                                       selected = "rows"),
                          
                          actionButton('submit-row-delete', 'Delete selected')
                          
                        ),
                        
                        # Main panel for displaying outputs ----
                        mainPanel(
                          
                          # Output: Data file ----
                          DT::dataTableOutput('table1'),
                          DT::dataTableOutput("table2")
                          
                        )
                        
                      )),
             tabPanel("IDK")
  )
)