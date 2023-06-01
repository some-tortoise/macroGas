library('googledrive')
library('readr')
library('tidyverse')

google_drive_auth <- function(){
  drive_auth(
    email = gargle::gargle_oauth_email(),
    path = NULL,
    scopes = "https://www.googleapis.com/auth/drive",
    cache = gargle::gargle_oauth_cache(),
    use_oob = gargle::gargle_oob_default(),
    token = NULL
  )
}

download_csv_files <- function(){
  macro_folder <- 'https://drive.google.com/drive/u/0/folders/12bxB-gn3DvutNcwmH8CO1er3ngmCjdlo'
  folder_id = drive_get(as_id(macro_folder))
  files = drive_ls(folder_id) # gets files from inside folder
  vector_of_CSVs <- c(as.data.frame(files[1]))[[1]] # column 1 tells it to grab first column with names of csv
  num_files <- length(vector_of_CSVs) # number of files in the google drive
  data_list <- list() # list of CSVs in the order they are in google drive.
  
  for (x in 1:num_files) {
    currentCSV <- vector_of_CSVs[x] 
    drive_download(currentCSV, overwrite = TRUE, type = 'csv') # overwrite = TRUE tells us to overwrite local copies of the files. This is extremely inefficient, but does not work if I don't do it so......
    foo <- read_csv(currentCSV, skip = 1)
    data_list[[x]] <- foo
    print(data_list[[x]])
  }
  data_list <- lapply(data_list, as.data.frame)
  return(data_list)
}

clean_csv_files <- function(df){
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
  return(out)
}

#google_drive_auth()
data_list <- download_csv_files() # use data_list[[x]] to get the x'th tibble. Range from 1:num_files
num_files <- length(data_list)

clean_data_list <- list()
for (x in seq(1:num_files)){
  clean_data_list[[x]] <- clean_csv_files(data_list[[x]])
}

view(clean_data_list[[2]])
