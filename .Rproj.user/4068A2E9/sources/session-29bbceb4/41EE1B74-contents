############
##Trimming##
############

# !!!!need combined_df from updated_cleaning.R for it to work##
#filter the data to just one station (in this case 1), and to within an hour on each side of the slug 
station1_slug <- combined_df %>% filter(station == '3')
station1_slug <- station1_slug %>%
  filter(substr(Date_Time, 12, 19) >= "13:20:00" & substr(Date_Time, 12, 19) <= "18:33:00") # gets only the time from the date time
station1_slug <- station1_slug %>%
  mutate(id = row_number())

#Create a new large_change column that is TRUE if Low_Range changes by more than .1, NA otherwise
large_change <- ifelse(abs(station1_slug$Low_Range - lag(station1_slug$Low_Range, 20)) > 0.1, TRUE, NA)
station1_slug <- station1_slug %>%
  mutate(large_change = large_change) %>%
  relocate(large_change, .after = Low_Range)

#use an RLE to identify the index of the longest string of TRUE (this is the slug)
longest_true <- rle(station1_slug$large_change)
longest_true_index <- with(rle(station1_slug$large_change), {
  starts <- cumsum(lengths) - lengths + 1
  ends <- cumsum(lengths)
  lengths <- lengths[values]
  start_index <- starts[which.max(lengths)]
  end_index <- ends[which.max(lengths)]
  c(start_index, end_index)
})

#trim the dataframe to just the slug
start_trim <- longest_true_index[1] - 10
end_trim <- longest_true_index[2] + 10
trimmed_station1_slug <- station1_slug[start_trim:end_trim, ]

#plot the trimmed slug
x <- trimmed_station1_slug$Date_Time
y <- trimmed_station1_slug$Low_Range
plot(x,y)


