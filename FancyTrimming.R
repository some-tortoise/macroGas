############
##Trimming##
############

# !!!!need combined_df from updated_cleaning.R for it to work##
#grabs station and filters out first eensy bit of bad data
station1_slug <- combined_df %>% filter(station == '1')
station1_slug <- station1_slug %>%
  filter(substr(Date_Time, 12, 19) >= "13:20:00") # gets only the time from the date time
station1_slug$Date_Time = as.numeric(station1_slug$Date_Time)

#gets points above mean
mean <- mean(station1_slug$Low_Range)
above_line_df <- station1_slug[mean < station1_slug$Low_Range, ]

#grabs the largest cluster and puts those data points into selected_points
#just grabs first cluster I think. NEEDS TO BE THE BIGGEST ONE. NOT FIXED
small_df <- above_line_df[, c('Date_Time', 'Low_Range')]
dbscan_res <- dbscan(small_df, eps = 100, minPts = 10)
selected_points <- above_line_df[dbscan_res$cluster+1 == 2,]

#expands range to include nearby points as well
distance_threshold <- 500
nearby_points <- station1_slug[station1_slug$Date_Time > min(selected_points$Date_Time) - distance_threshold &
                                 station1_slug$Date_Time < max(selected_points$Date_Time) + distance_threshold, ]

#plots data
x <- nearby_points$Date_Time
y <- nearby_points$Low_Range
plot(x,y)

abline(h=mean)
