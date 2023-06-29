library(tidyverse)
library(dplyr)
library(lubridate)

####HALF HEIGHT MATH####

# C(half height) = C (background) + 1/2(C max - C background) #
# this will work if the slug is already trimmed -- see plot #

path <- '/Users/annacspitzer/Desktop/slugtemplate.csv'
slugtemplate <- read.csv(path) #this is just the template we have on upload page

#convert times 
slugtemplate$Date_Time <- mdy_hms(slugtemplate$Date_Time, truncated = 2)
class(slugtemplate$Date_Time)

#check it's trimmed
x <- slugtemplate$Date_Time
y <- slugtemplate$Low_Range_μS_cm
plot(x,y)

#calculate half height
background <- slugtemplate$Low_Range_μS_cm[1]
Cmax <- max(slugtemplate$Low_Range_μS_cm)
Chalf <- background + (1/2) * (Cmax - background)
print(Chalf)

#calculate time to half height 
index_Cmax <- which(slugtemplate$Low_Range_μS_cm == Cmax) #half-height has to occur before the peak -- can't identify point on the backside
closest_index <- which(slugtemplate$Low_Range_μS_cm <= Chalf & seq_along(slugtemplate$Low_Range_μS_cm) < index_Cmax) #identifies just the stuff before the peak
index_Chalf <- closest_index[length(closest_index)]

start_time <- slugtemplate$Date_Time[1]
Chalf_time <- slugtemplate$Date_Time[index_Chalf]
time_to_half <- (Chalf_time - start_time)
print(time_to_half)
          
