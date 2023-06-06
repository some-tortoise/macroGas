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
             tabPanel("Upload"),
             tabPanel("IDK")
  )
)