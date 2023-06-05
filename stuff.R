library('googledrive')
library('readr')
library('tidyverse')
library('lubridate')
library('gargle')

#
# GLOBAL VARS
#
raw_folder <- 'https://drive.google.com/drive/u/0/folders/1G1lauwH1H3Ds92ReuW6S2DNijWrXCB3Q'
processed_folder <- 'https://drive.google.com/drive/u/0/folders/1oApNS0FhID95xUn0R0q9BMxe0LzqNSjs'

#
# FUNCTIONS
#

google_drive_auth <- function(){
  drive_auth(
    email = gargle_oauth_email(),
    path = NULL,
    scopes = "https://www.googleapis.com/auth/drive",
    cache = gargle_oauth_cache(),
    use_oob = gargle_oob_default(),
    token = NULL
  )
}

download_csv_files <- function(){
  folder_id <- drive_get(as_id(raw_folder))
  files <- drive_ls(folder_id) # gets files from inside folder
  list_of_raw_names <- select(files, 'name')
  vector_of_CSVs <- c(as.data.frame(files[1]))[[1]] # column 1 tells it to grab first column with names of csv
  num_files <- length(vector_of_CSVs) # number of files in the google drive
  data_list <- list() # list of CSVs in the order they are in google drive.
  
  for (x in 1:num_files) {
    currentCSV <- vector_of_CSVs[x] 
    drive_download(currentCSV, overwrite = TRUE, type = 'csv') # overwrite = TRUE tells us to overwrite local copies of the files. This is extremely inefficient, but does not work if I don't do it so......
    data_list[[x]] <- read_csv(currentCSV, skip = 1) 
    print(data_list[[x]]) # just for visuals during the downloading process
  }
  data_list <- lapply(data_list, as.data.frame) # turns the tibble into a dataframes
  
  out <- list(data_list,list_of_raw_names)
  return(out)
}

clean_csv_file <- function(df, x){
  df <- df[0:5]
  colnames(df) <- c('V1','V2','V3', 'V4', 'V5')
  
  out <-  
    df |>
    select(-c("V1")) |>
    rename(Date_Time = V2, Low_Range = V3, Full_Range = V4, Temp_C = V5) |>
    slice(-1) #|>
    #separate(Date_Time, into = c("Date", "Time"), sep = " ")
  
  
  out <- out |>
    mutate(Low_Range = as.numeric(Low_Range)) |>
    mutate(Full_Range = as.numeric(Full_Range)) |>
    mutate(Temp_C = as.numeric(Temp_C))
  
  
  #out$Date_Time <-  as.POSIXct(out$Date_Time, format = "%m/%d/%y %H:%M:%S", tz = "UTC" )
  out$Date_Time <- mdy_hms(out$Date_Time, tz='GMT')
  out$station = x
  return(out)
}

clean_csv_files <- function(dfs){
  num_files <- length(dfs)
  clean_data_list <- list()
  for (x in seq(1:num_files)){
    clean_data_list[[x]] <- clean_csv_file(dfs[[x]], x)
  }
  return(clean_data_list)
}

upload_csv_file <- function(clean_df, name){
  file <- name
  file <- drive_put(
    media = file,
    name = paste('processed_',name, sep=''),
    type = 'csv',
    path = as_id(processed_folder))
  print(2)
}

turn_file_to_csv <- function(clean_df){
  write.csv(clean_df, "./chicken.csv", row.names=FALSE)
}

upload_files <- function(clean_dfs, list_of_raw_names){
  for(x in seq(1:length(clean_dfs))){
    turn_file_to_csv(clean_dfs[[x]])
    upload_csv_file(clean_dfs[[x]], as.character(nth(list_of_raw_names, x)))
  }
}

#google_drive_auth()
download_output <- download_csv_files() # use data_list[[x]] to get the x'th tibble. Range from 1:num_files
data_list <- download_output[[1]]
list_of_raw_names <- download_output[[2]]

clean_data_list <- clean_csv_files(data_list)

combined_df = do.call(rbind, clean_data_list)

upload_files(clean_data_list, list_of_raw_names)
