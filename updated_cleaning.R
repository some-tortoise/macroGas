library(googledrive)
library(tidyverse)
library(lubridate)
library(readr)
drive_auth()

macro_link = "https://drive.google.com/drive/u/0/folders/1G1lauwH1H3Ds92ReuW6S2DNijWrXCB3Q"
names = drive_ls(macro_link)[['name']]

df = c()
for(i in 1:length(names)){
  name = names[i]
  file <- drive_get(name)
  drive_download(file, path = name, overwrite = TRUE)
  loaded = read.csv(name, header=F)
  loaded = loaded[-c(1,2),1:5]
  colnames(loaded) <- c('id', 'Date_Time', 'Low_Range', 'Full_Range', 'Temp_C')
  loaded = loaded %>% 
    mutate_at(vars(-Date_Time), as.numeric) %>%
    mutate(Date_Time = mdy_hms(Date_Time, tz='GMT'),
           station = i)
  df[[i]] = loaded
}

combined_df = do.call(rbind, df)