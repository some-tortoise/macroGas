library(googledrive)
library(tidyverse)
library(lubridate)
library(readr)

#drive_auth()

raw_folder <- 'https://drive.google.com/drive/u/0/folders/1G1lauwH1H3Ds92ReuW6S2DNijWrXCB3Q'
list_of_raw_csv_names = drive_ls(raw_folder)[['name']] #gives us file names from google drive

get_and_clean_data <- function(){
  df = c() #creates an empty vector
  for(i in 1:length(list_of_raw_csv_names)){ #for each name in however many files we have, do the following:
    name <- list_of_raw_csv_names[i] #gets first name
    file <- drive_get(name) #if there is a csv by this name, get it.
    drive_download(file, path = name, overwrite = TRUE) # downloads a particular file
    loaded = read.csv(name, header=F) #loads file into r environment
    loaded = loaded[-c(1,2),1:5] #deleting first two columns and then keeping remaining 5
    colnames(loaded) <- c('id', 'Date_Time', 'Low_Range', 'Full_Range', 'Temp_C') #naming columns
    loaded = loaded %>% #saves following code as loaded
      mutate_at(vars(-Date_Time), as.numeric) %>% #changes every variable but date_time to numeric
      mutate(Date_Time = mdy_hms(Date_Time, tz='GMT'), #changes date_time to a mdy_hms format in gmt time zone
             station = i) #FIX THIS- stations are not ordered by station number
    df[[i]] = loaded #makes the ith element of the list equal to the data frame.
  }
  return(df)
}

clean_dataframe_list <- get_and_clean_data()
combined_df <- do.call(rbind, clean_dataframe_list) #combining all data frames - function binding rows
combined_df <- combined_df |>
  mutate(Low_Range_Flag = 'good',
         Full_Range_Flag = 'good',
         Temp_C_Flag = 'good')

view(combined_df)


