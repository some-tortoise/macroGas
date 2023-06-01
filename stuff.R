library('googledrive')
library('readr')

drive_auth(
  email = gargle::gargle_oauth_email(),
  path = NULL,
  scopes = "https://www.googleapis.com/auth/drive",
  cache = gargle::gargle_oauth_cache(),
  use_oob = gargle::gargle_oob_default(),
  token = NULL
)

macro_folder <- 'https://drive.google.com/drive/folders/1QhIzFToANF5JNOyxp2_q6WGaFrFUM3iA'
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

data_list[[2]]
