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


raw_folder <- 'https://drive.google.com/drive/u/0/folders/1hniqK4ouIs3mFC8utRoiRfWgk1Ct-m9k'
list_of_raw_csv_names = drive_ls(raw_folder)[['name']] #gives us file names from google drive

##at this point -- select 1 when prompted to give tidyverse API access to your google drive##
##then run the rest of the code 

get_and_clean_data <- function(){
  df = c() #creates an empty vector
  for(i in 1:length(list_of_raw_csv_names)){ #for each name in however many files we have, do the following:
    name <- list_of_raw_csv_names[i] #gets first name
    file <- drive_get(name)[1,] #if there is a csv by this name, get it.
    drive_download(file, path = name, overwrite = TRUE) # downloads a particular file
    loaded = read.csv(name, header=F) #loads file into r environment
    loaded = loaded[-c(1),1:3] #deleting first two columns and then keeping remaining 5
    colnames(loaded) <- c('Date_Time', 'DO_conc', 'Temp_C') #naming columns
    loaded = loaded %>% #saves following code as loaded
      mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
      mutate(Date_Time = mdy_hms(Date_Time, tz='GMT')) #changes date_time to a mdy_hms format in gmt time zone
    df[[i]] = loaded #makes the ith element of the list equal to the data frame.
  }
  return(df)
}

clean_dataframe_list <- get_and_clean_data()
combined_df <- do.call(rbind, clean_dataframe_list)

ui <- fluidPage(
  navbarPage('Gas App',
              theme = shinytheme("flatly"),
             useShinyjs(),
             tabPanel('Home',
                      source("ui/homeUI.R")[1]),
             tabPanel('QA/QC',
                      source("ui/qaqcUI.R")[1])
  )
    
)

server <- function(input, output, session) {
  goop <- reactiveValues()
  goop$combined_df <- combined_df
  
  # Call the server functions from the included files
  source("server/qaqcserver.R", local = TRUE)
}


shinyApp(ui, server)
