library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(pracma) #integrals

#calculate fraction of observations that are 
#hypoxic at night / fractions hypoxic during the day


#axes of the graph are x = DO (% sat) and y = probability density
#one line is probability 
path <- "/Users/annacspitzer/Desktop/erwin_downstream_DO.csv" 
exampledata <- read.csv(path)

#deal with the datetime column
exampledata$Date_Time <- mdy_hms(exampledata$Date_Time)

#extract hour using lubridate and move the column to after Date_Time
exampledata$Hour <- lubridate::hour(exampledata$Date_Time)

# assuming sun sets at 8PM rises at 6AM
# light data fram, 6AM to 8PM
# light_df <- filter(exampledata, Hour %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20))

# dark data fram, 8PM to 6AM
# dark_df <- filter(exampledata, Hour %in% c(21, 22, 23, 0, 1, 2, 3, 4, 5))

#hypoxia threshold
h <- 4

##### june 15th through 17th #####
june15 <- exampledata[1398:1686, ]
june15_dark <- filter(june15, Hour %in% c(21, 22, 23, 0, 1, 2, 3, 4, 5))
june15_light <- filter(june15, Hour %in% c(6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20))

#light probability density
n_light <- nrow(june15_light) #gets number of  observations
hypoxic_n_light <- sum(june15_light$DO_conc < h, na.rm = TRUE) #gets number of hypoxic observations
light_prob_dens <- (hypoxic_n_light/n_light)
print("Light probability density")
print(light_prob_dens)

#dark probability density
n_dark <- nrow(june15_dark)
hypoxic_n_dark <- sum(june15_dark$DO_conc < h, na.rm = TRUE)
dark_prob_dens <- (hypoxic_n_dark/n_dark)
print("Night probability density")
print(dark_prob_dens)

#Night hypoxia ratio
nhr <- (dark_prob_dens/light_prob_dens)
print("Night Hypoxia Ratio")
print(nhr)


##### PROBABILITY DENSITY OF BOTH #####
cleaned_data <- june15[!is.na(june15$DO_conc), ]
kde_all <- density(cleaned_data$DO_conc)
plot_all <- data.frame(DO = kde_all$x, Density = kde_all$y)
ggplot(plot_all, aes(x = DO, y = Density)) +
  geom_line() +
  labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
  ggtitle("Probability Density of Dissolved Oxygen (BOTH)")


##### PROBABILITY DENSITY OF NIGHT ######
kde_dark <- density(june15_dark$DO_conc)
plot_dark <- data.frame(DO = kde_dark$x, Density = kde_dark$y)
ggplot(plot_dark, aes(x = DO, y = Density)) +
  geom_line() +
  geom_vline(xintercept = h, color = "red") +  # Add a vertical line at x = 8
  geom_ribbon(data = subset(plot_dark, DO <= h), aes(x = DO, ymin = 0, ymax = Density),
              fill = "darkblue", alpha = 0.3) +  # Shade to the left of the line
  labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
  ggtitle("Erwin Downstream June 15-17: Dark")

subset_df_dark <- subset(plot_dark, DO >= min(DO) & DO <= h)
integral_dark <- trapz(subset_df_dark$DO, subset_df_dark$Density)

##### PROB DENSITY OF DAY #####
cleaned_light_df <- june15_light[!is.na(june15_light$DO_conc), ]
kde_light <- density(cleaned_light_df$DO_conc)
plot_light <- data.frame(DO = kde_light$x, Density = kde_light$y)
ggplot(plot_light, aes(x = DO, y = Density)) +
  geom_line() +
  geom_vline(xintercept = h, color = "red") +  
  geom_ribbon(data = subset(plot_light, DO <= h), aes(x = DO, ymin = 0, ymax = Density),
              fill = "red", alpha = 0.3) +  # Shade to the left of the line
  labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
  ggtitle("Erwin Downstream June 15-17: Light")

subset_df_light <- subset(plot_light, DO >= min(DO) & DO <= h)
integral_light <- trapz(subset_df_light$DO, subset_df_light$Density)



