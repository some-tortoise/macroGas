library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(pracma) #integrals

path <- "/Users/annacspitzer/Desktop/erwin_downstream_DO.csv" 
exampledata <- read.csv(path)
exampledata$Date_Time <- mdy_hms(exampledata$Date_Time)

#inputs
start_date_time <- "2023-06-15 00:00:00"
end_date_time <- "2023-06-17 11:59:00"
sunrise <- "06:00:00"
sunset <- "20:00:00"
h <- 4
data <- exampledata

## can run all these in order and will get you new light/dark dataframes and calculate all the probabilities ##
clean_DO_data(data, start_date_time, end_date_time)
get_dark_light_df(clean_data, sunrise, sunset)
light_prob_fxn(light_df, h)
dark_prob_fxn(dark_df, h)
night_hyp_ratio(dark_prob_dens, light_prob_dens)


## functions ##
clean_DO_data <- function(data, start_date_time, end_date_time) {
  clean_data <- data %>% 
    mutate(Date_Time = ymd_hms(Date_Time)) %>%
    filter(Date_Time >= ymd_hms(start_date_time) & Date_Time <= ymd_hms(end_date_time)) %>%
    mutate(Hour = hour(Date_Time)) %>%
    mutate(Minute = minute(Date_Time))
  
  clean_data <<- clean_data
  return(clean_data)
  
  }
get_dark_light_df <- function(clean_data, sunrise, sunset) {

#Fix formatting of dates and add an hour and minute column 
  sunrise_time <- hms(sunrise)
  sunset_time <- hms(sunset)
  
  light_df <<- clean_data %>%
    filter(Hour > hour(sunrise_time) | (Hour == hour(sunrise_time) & Minute >= minute(sunrise_time))) %>%
    filter(Hour < hour(sunset_time) | (Hour == hour(sunset_time) & Minute <= minute(sunset_time)))
  
  dark_df <<- clean_data %>%
    filter(Hour > hour(sunset_time) | (Hour == hour(sunset_time) & Minute >= minute(sunset_time)) | (Hour < hour(sunrise_time) | (Hour == hour(sunrise_time) & Minute <= minute(sunrise_time))))
  
}
light_prob_fxn <- function(light_df, h) {
  n_light <- nrow(light_df)
  hypoxic_n_light <- sum(light_df$DO_conc < h, na.rm = TRUE) #gets number of hypoxic observations
  light_prob_dens <<- (hypoxic_n_light/n_light)
  print("Light probability density")
  print(light_prob_dens)
}
dark_prob_fxn <- function(dark_df, h) {
  n_dark <- nrow(dark_df)
  hypoxic_n_dark <- sum(dark_df$DO_conc < h, na.rm = TRUE)
  dark_prob_dens <<- (hypoxic_n_dark/n_dark)
  print("Night probability density")
  print(dark_prob_dens)
}
night_hyp_ratio <- function(dark_prob_dens, light_prob_dens) {
  nhr <<- (dark_prob_dens/light_prob_dens)
  
  print("Night Hypoxia Ratio")
  print(nhr)
  return(nhr)
}

## GRAPH AND INTEGRAL FUNCTION ##
plot_density <- function(df) {
  kde <- density(df$DO_conc)
  plot <- data.frame(DO = kde$x, Density = kde$y)
  ggplot(plot, aes(x = DO, y = Density)) +
    geom_line() +
    geom_vline(xintercept = h, color = "red") +
    geom_ribbon(data = subset(plot, DO <= h), aes(x = DO, ymin = 0, ymax = Density),
                fill = "darkblue", alpha = 0.3) +
    labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
    ggtitle("Erwin Downstream June 15-17")
  
  subset_df <- subset(plot, DO >= min(DO) & DO <= h)
  integral <<- trapz(subset_df$DO, subset_df$Density)
  
}

## define your dataframe (either light, dark, or whole) and then run this function
# input example: df <- light_df
plot_density(df)

##### PROBABILITY DENSITY OF NIGHT PLOT FXN ######
plot_density <- function(df) {
  kde <- density(df$DO_conc)
  plot <- data.frame(DO = kde$x, Density = kde$y)
  ggplot(plot, aes(x = DO, y = Density)) +
    geom_line() +
    geom_vline(xintercept = h, color = "red") +
    geom_ribbon(data = subset(plot, DO <= h), aes(x = DO, ymin = 0, ymax = Density),
                fill = "darkblue", alpha = 0.3) +
    labs(x = "Dissolved Oxygen (mg/L)", y = "Probability Density") +
    ggtitle("Erwin Downstream June 15-17")
  
  subset_df <- subset(plot, DO >= min(DO) & DO <= h)
  integral_prob <<- trapz(subset_df$DO, subset_df$Density)
  
  
}
 


