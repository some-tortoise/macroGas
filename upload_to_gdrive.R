library(googledrive)
library(tidyverse)
library(lubridate)
library(readr)
source(knitr::purl("updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

processed_folder <- 'https://drive.google.com/drive/u/0/folders/1oApNS0FhID95xUn0R0q9BMxe0LzqNSjs'

upload_csv_file <- function(clean_df, name){
  file <- paste('processed_',name, sep='')
  file <- drive_put(
    media = file,
    name = file,
    type = 'csv',
    path = as_id(processed_folder))
}

turn_file_to_csv <- function(clean_df, name){
  write.csv(clean_df, paste('./processed_',name, sep=''), row.names=FALSE)
}

upload_files <- function(clean_dfs, names){
  for(x in seq(1:length(clean_dfs))){
    name <- as.character(nth(names, x))
    turn_file_to_csv(clean_dfs[[x]], name)
    upload_csv_file(clean_dfs[[x]], name)
  }
}

upload_files(clean_dataframe_list, list_of_raw_csv_names)