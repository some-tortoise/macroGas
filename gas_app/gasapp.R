library(shiny) # for webpage creation
library(tidyverse)
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
library(shinythemes)
library(lubridate)
library(reshape2)
library(janitor)
library(remotes)
# remotes::install_github("USGS-R/streamMetabolizer") # RUN THIS TO INSTALL STREAMMETABOLIZER
library(streamMetabolizer)


raw_folder <- 'https://drive.google.com/drive/u/0/folders/1hniqK4ouIs3mFC8utRoiRfWgk1Ct-m9k'
list_of_raw_csv_names = drive_ls(raw_folder)[['name']] #gives us file names from google drive
list_of_raw_csv_id = drive_ls(raw_folder)[['id']]
##at this point -- select 1 when prompted to give tidyverse API access to your google drive##
##then run the rest of the code 

get_and_clean_data <- function(){
  df = c() #creates an empty vector
  for(i in 1:length(list_of_raw_csv_names)){ #for each name in however many files we have, do the following:
    name <- list_of_raw_csv_names[i] #gets first name
    station_name <- strsplit(name,'_')[[1]][2] #gets station name
    id = as_id(list_of_raw_csv_id[i])
    file <- drive_get(id)[1,] #if there is a csv by this name, get it.
    drive_download(file, path = name, overwrite = TRUE) # downloads a particular file
    loaded = read.csv(name, header = FALSE) #loads file into r environment
    loaded = loaded[-1] #deleting first column
    loaded = loaded[1:3] #keeping first 3 columns
    colnames(loaded) <- c('Date_Time', 'DO_conc', 'Temp_C') #naming columns
    loaded <- slice(loaded, -(1:2))
    loaded = loaded %>% #saves following code as loaded
      mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
      mutate(Date_Time = parse_date_time(Date_Time, "%m/%d/%y %I:%M:%S %p"),
              station = station_name) 
    df[[i]] = loaded #makes the ith element of the list equal to the data frame.
  }
  return(df)
}

clean_dataframe_list <- get_and_clean_data()
combined_df <- do.call(rbind, clean_dataframe_list)
combined_df <- melt(combined_df, id.vars = c("Date_Time", "station"), measure.vars = c("DO_conc", "Temp_C"))
combined_df <- combined_df |>
  rename(Variable = variable,
         Station = station,
         Value = value)
combined_df <- combined_df %>% mutate(Flag = "NA", id = row.names(.))

ui <- fluidPage(
  class = 'body-container',
  theme = shinytheme("flatly"),
  tags$head(
    HTML(
      '<link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap" rel="stylesheet">'
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  navbarPage('Gas App',
              theme = shinytheme("flatly"),
             useShinyjs(),
             tabPanel('Home',
                      source("ui/homeUI.R")[1]),
             tabPanel('QA/QC',
                      source("ui/qaqcUI.R")[1]),
            
             tabPanel("View",
                     source("ui/viewUI.R")[1]),
             tabPanel("DO Data and Metrics",
                      source("ui/DOUI.R")[1])
             )
  
  )

server <- function(input, output, session) {
  goop <- reactiveValues()
  goop$combined_df <- combined_df
  
  # Call the server functions from the included files
  source("server/homeserver.R", local = TRUE)
  source("server/qaqcserver.R", local = TRUE)
  source("server/viewserver.R", local = TRUE)
  source("server/DOserver.R", local = TRUE)
}


shinyApp(ui, server)
