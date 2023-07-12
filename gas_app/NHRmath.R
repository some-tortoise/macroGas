library(lubridate)

#calculate fraction of observations that are 
#hypoxic at night / fractions hypoxic during the day


#axes of the graph are x = DO (% sat) and y = probability density
#one line is probability 

#extract hour using lubridate and move the column to after Date_Time
combined_df$Hour <- lubridate::hour(combined_df$Date_Time)
combined_df <- select(combined_df, Date_Time, Hour, everything())

#assuming sun sets at 8PM rises at 6AM
#light data fram, 6AM to 8PM
light_df <- filter(combined_df, Hour %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19))
light_df <- filter(light_df, Variable != "Temp_C") #get rid of temp data

#dark data fram, 8PM to 6AM
dark_df <- filter(combined_df, Hour %in% c(20, 21, 22, 23, 0, 1, 2, 3, 4, 5))
dark_df <- filter(dark_df, Variable != "Temp_C") #get rid of temp data

#hypoxia threshold
h <- 11

#light probability density
n_light <- nrow(light_df) #gets number of  observations
hypoxic_n_light <- sum(light_df$Value < h, na.rm = TRUE) #gets number of hypoxic observations
light_prob_dens <- (hypoxic_n_light/n_light)

#dark probability density
n_dark <- nrow(dark_df)
hypoxic_n_dark <- sum(dark_df$Value < h, na.rm = TRUE)
dark_prob_dens <- (hypoxic_n_dark/n_dark)

#Night hypoxia ratio
nhr <- (dark_prob_dens/light_prob_dens)

