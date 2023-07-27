library(httr)
library(jsonlite)
library(tidyverse)

res = GET("https://archive-api.open-meteo.com/v1/archive?latitude=35.3268&longitude=-78.6761&start_date=2020-06-08&end_date=2023-07-22&hourly=temperature_2m,relativehumidity_2m,rain,snowfall,cloudcover,windspeed_10m,is_day,direct_radiation&timezone=America%2FNew_York")
data = as.data.frame(fromJSON(rawToChar(res$content)))
print(names(data))
#View(data)
#print(data$hourly.time)
#print(data$hourly.is_day)

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.is_day)) + 
  geom_point()

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.rain)) + 
  geom_point()

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.temperature_2m)) + 
  geom_point()

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.direct_radiation)) + 
  geom_point()

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.windspeed_10m)) + 
  geom_point()

ggplot(data = data, mapping = aes(x = hourly.time, y = hourly.cloudcover)) + 
  geom_point()
