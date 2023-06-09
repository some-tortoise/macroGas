library(tidyr)
library(dplyr)

## Trying to figure out math ##

##get cleaned data via our other code## (this doesn't work and I don't know why I've just been running updated_cleaning.R manually)
source(knitr::purl("../updated_cleaning.R", output = tempfile(), quiet = TRUE)) 
 

##filter the cleaned dataframe to just station 1##
station1_data <- combined_df %>% filter(station == "1")

##need to filter to an hour before and after the slug and plot it#
#in station 1 we know this is 13:33 -- at some point need to code this to be inputtable in shiny##
station1_slug <- station1_data %>% 
  filter(substr(Date_Time, 12, 19) >= "12:33:00" & substr(Date_Time, 12, 19) <= "14:33:00")

##need to find a value for background conductivity, average the values of 13:23:00 to 13:33:00##
background_cond <- mean(station1_slug$Low_Range[substr(station1_slug$Date_Time, 12, 19) >= "13:23:00" & substr(station1_slug$Date_Time, 12, 19) <= "13:33:00"])


#trim the data to the beginning of the slug where it's > background_cond
station1_slug <- station1_slug %>%
  filter(Low_Range >= background_cond)

#find conductivity that it settles at post-slug, doing so by identifying where Low_Range changes by more than .1
#then filtering to before and after twenty entries
no_change <- abs(station1_slug$Low_Range - lag(station1_slug$Low_Range)) <= 0.1
station1_slug <- station1_slug %>%
  mutate(no_change = no_change) %>%
  relocate(no_change, .after = Low_Range)
station1_slug$no_change[is.na(station1_slug$no_change)] <- TRUE #replace the NA at the beginning w/ true just to make life easier
station1_slug$no_change <- as.character(station1_slug$no_change) #make character instead of logical, again life = easier

rle_obj <- rle(station1_slug$no_change == "FALSE")
longest_run_length <- max(rle_obj$lengths[rle_obj$values])
start_index <- (sum(rle_obj$lengths[1:(which.max(rle_obj$lengths[rle_obj$values]) - 1)]) + 1) - 20
end_index <- ((start_index + longest_run_length - 1 + 40)) #the last two lines make the indexes +/- 20 on each side of the slug
trimmed_station1_slug <- station1_slug[start_index:end_index, ]

#check with a little plot
x <- station1_slug$Date_Time
y <- station1_slug$Low_Range
plot(x, y)


# Trim the dataframe based on the calculated indices




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
##need to filter to start calculating when the Low_Range is > background_cond and stop when < background_cond##
station1_curve <- station1_slug %>%
    filter(Low_Range)

