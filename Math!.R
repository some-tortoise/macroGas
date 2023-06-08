library(tidyr)

## Trying to figure out math ##

##get cleaned data via our other code##
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) #gets cleaned data

##filter the cleaned dataframe to just station 1##
station1_data <- combined_df %>% filter(station == "1")

##need to filter to an hour before and after the slug#
#in station 1 we know this is 13:33 -- at some point need to code this to be inputtable in shiny##
station1_slug <- station1_data %>% 
  filter(substr(Date_Time, 12, 19) >= "12:33:00" & substr(Date_Time, 12, 19) <= "14:33:00")

##need to find a value for background conductivity, average the values of 12:33:00 to 13:33:00##
background_cond <- mean(station1_slug$Low_Range)

##need to create a NaCl concentration (in g/L) column##
##also an area column##
station1_slug <- station1_slug %>%
  mutate(NaCl_Conc = NA) %>%
  relocate(NaCl_Conc, .after = Temp_C)
station1_slug <- station1_slug %>%
  mutate(Area = NA) %>%
  relocate(Area, .after = NaCl_Conc)

##NaCl concentration is the (low range value - background_cond) * .00047##
station1_slug <- station1_slug %>%
  mutate(NaCl_Conc = (Low_Range - background_cond) * 0.00047)

##area under the curve is the time between conductivity recordings (in this case 5 sec) * NaCl conc ##
##again, need to figure out how to make that 5sec value inputtable into Shiny##
station1_slug <- station1_slug %>%
    mutate(Area = (NaCl_Conc * 5))

##calculate the area under the curve##
##need to filter to when the Low_Range is > background_cond##
