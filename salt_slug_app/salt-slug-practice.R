## ----------------------------------------------------------------------
library(tidyverse)
library(googledrive)
library(googlesheets4)
library(lubridate)


## ----------------------------------------------------------------------
id = "1oN30VFTWRDMB7jwRNANu47L183L2G25_"
copy_mgas_erwin_station_1_2023_05_25 <- read.csv(sprintf("https://docs.google.com/uc?id=%s&export=download", id), header = FALSE)


## ----------------------------------------------------------------------
view(copy_mgas_erwin_station_1_2023_05_25)


## ----------------------------------------------------------------------
organized_mgas_erwin_station_1_2023_05_25 <-  
copy_mgas_erwin_station_1_2023_05_25 |>
  slice(2:11805)|>
  select(-c("V1", "V6", "V7")) |>
  rename(Date_Time = V2, Low_Range = V3, Full_Range = V4, Temp_C = V5) |>
  slice(-1) |>
  separate(Date_Time, into = c("Date", "Time"), sep = " ")


## ----------------------------------------------------------------------
#|view-cleaned-file
view(organized_mgas_erwin_station_1_2023_05_25)


## ----------------------------------------------------------------------
organized_mgas_erwin_station_1_2023_05_25 <- organized_mgas_erwin_station_1_2023_05_25 |>
 mutate(Low_Range = as.numeric(Low_Range)) |>
  mutate(Full_Range = as.numeric(Full_Range)) |>
  mutate(Temp_C = as.numeric(Temp_C))
  


## ----------------------------------------------------------------------
organized_mgas_erwin_station_1_2023_05_25$Date <-  as.POSIXct(organized_mgas_erwin_station_1_2023_05_25$Date, format = "%m/%d/%y", tz = "UTC" )

#organized_mgas_erwin_station_1_2023_05_25$Date = #sapply(organized_mgas_erwin_station_1_2023_05_25$Date,)


## ----------------------------------------------------------------------


## ----------------------------------------------------------------------
#|making-graph
select
organized_mgas_erwin_station_1_2023_05_25[organized_mgas_erwin_station_1_2023_05_25$Date==as.Date('2023-05-25'), ] 
  ggplot(organized_mgas_erwin_station_1_2023_05_25, aes(x = Time, y = Temp_C)) +
  geom_point() +
  geom_line() 
  
  


