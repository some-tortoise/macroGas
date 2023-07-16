library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)

#calculate fraction of observations that are 
#hypoxic at night / fractions hypoxic during the day


#axes of the graph are x = DO (% sat) and y = probability density
#one line is probability 
path <- "/Users/annacspitzer/Desktop/example.csv"

exampledata <- read.csv(path) %>%
  dplyr::rename(Date_Time = Date.Time..GMT.04.00) %>%
  dplyr::rename(Temp_C = Temp...C..LGR.S.N..10808939..SEN.S.N..10808939.) %>%
  dplyr::rename(DO_conc = DO.conc..mg.L..LGR.S.N..10808939..SEN.S.N..10808939.) 

#deal with the datetime column
exampledata$Date_Time <- mdy_hms(exampledata$Date_Time)

#extract hour using lubridate and move the column to after Date_Time
exampledata$Hour <- lubridate::hour(exampledata$Date_Time)

#assuming sun sets at 8PM rises at 6AM
#light data fram, 6AM to 8PM
light_df <- filter(exampledata, Hour %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20))

#dark data fram, 8PM to 6AM
dark_df <- filter(exampledata, Hour %in% c(21, 22, 23, 0, 1, 2, 3, 4, 5))

#hypoxia threshold
h <- 8

#light probability density
n_light <- nrow(light_df) #gets number of  observations
hypoxic_n_light <- sum(light_df$DO_conc < h, na.rm = TRUE) #gets number of hypoxic observations
light_prob_dens <- (hypoxic_n_light/n_light)
print(light_prob_dens)

#dark probability density
n_dark <- nrow(dark_df)
hypoxic_n_dark <- sum(dark_df$DO_conc < h, na.rm = TRUE)
dark_prob_dens <- (hypoxic_n_dark/n_dark)
print(dark_prob_dens)

#Night hypoxia ratio
nhr <- (dark_prob_dens/light_prob_dens)
print(nhr)

##### PROBABILITY DENSITY OF NIGHT ######
kde_dark <- density(dark_df$DO_conc)
plot_dark <- data.frame(DO = kde_dark$x, Density = kde$y)
ggplot(plot_dark, aes(x = DO, y = Density)) +
  geom_line() +
  labs(x = "DO (% saturation)", y = "Probability Density") +
  ggtitle("Probability Density of Dissolved Oxygen at Night")

##### PROB DENSITY OF DAY #####
kde_light <- density(light_df$DO_conc)
