library(fitdistrplus)

# !!!!need combined_df from updated_cleaning.R for it to work##
#grabs station and filters out first eensy bit of bad data
station1_slug <- combined_df %>% filter(station == '4')
station1_slug <- station1_slug %>%
  filter(substr(Date_Time, 12, 19) >= "13:20:00") #%>%
  #filter(substr(Date_Time, 12, 19) >= "18:50:00") # gets only the time from the date time
station1_slug$Date_Time <- as.numeric(station1_slug$Date_Time)

#create data frame
df <- data.frame(x=1:20,
                 y=c(3, 3.1, 4, 5, 5.5, 7, 9, 13, 18, 20, 19, 16, 12, 9, 8, 6,5,4,4,4))

#create a scatterplot of x vs. y
plot(df$x, df$y, pch=19, xlab='x', ylab='y')


# fit1 <- lm(y~x, data=df)
# fit2 <- lm(y~poly(x,2,raw=TRUE), data=df)
# fit3 <- lm(y~poly(x,3,raw=TRUE), data=df)
# fit4 <- lm(y~poly(x,4,raw=TRUE), data=df)
# fit5 <- lm(y~poly(x,5,raw=TRUE), data=df)
fit6 <- lm(y~exp((x*x)), data=df)

#create a scatterplot of x vs. y
plot(df$x, df$y, pch=19, xlab='x', ylab='y')

#define x-axis values
x_axis <- seq(1, 20, length=15)

#add curve of each model to plot
# lines(x_axis, predict(fit1, data.frame(x=x_axis)), col='green')
# lines(x_axis, predict(fit2, data.frame(x=x_axis)), col='red')
# lines(x_axis, predict(fit3, data.frame(x=x_axis)), col='purple')
# lines(x_axis, predict(fit4, data.frame(x=x_axis)), col='blue')
# lines(x_axis, predict(fit5, data.frame(x=x_axis)), col='orange')
lines(x_axis, predict(fit6, data.frame(x=x_axis)), col='orange')
lines(x_axis, predict(fm, data.frame(x=x_axis)), col='blue')
# plot(y ~ x, pch = 20)
# lines(fitted(fm) ~ x, col = "red")




c0 <- c1 <- 1
x <- 1:10
y <- c(0.6370996, 1.0755945, 1.5421652, 1.6164888, 1.8046882, 2.1174166, 2.1255332, 2.0707185, 2.2338998, 2.3533291)
# fit model to the data
fm <- nls(y ~ c0 * log(c1 * x + 1), start = list(c0 = mean(y), c1 = 1))
fm
plot(y ~ x, pch = 20)
lines(fitted(fm) ~ x, col = "red")



c0 <- c1 <- 1
x <- 1:10
y <- c(0.000133830225765, 
       0.000133830225765,
       0.0539909665132,
       0.241970724519,
       0.398942280401,
       0.241970724519,
       0.0539909665132,
       0.00443184841194,
       0.000133830225765,
       0.00000148671951473)
# fit model to the data
fm <- nls(y ~ (1/3.5)*(1/c0) * exp((-1/2)*(((x - c1)/c0) * ((x - c1)/c0)) ), start = list(c0 = 1, c1 = 10))
fm
plot(y ~ x, pch = 20)
lines(fitted(fm) ~ x, col = "red")




x <- 1:50
y <- c(3, 3.1, 4, 5, 5.5, 7, 9, 13, 18, 20, 
       19, 16, 12, 9, 8, 6,5,4,4,4,
       4,5,3,4,4,4,4.4,4.6,4,3.8,
       4,5,3,4,4,4,4.4,4.6,4,3.8,
       4,5,3,4,4,4,4.4,4.6,4,3.8)
# fit model to the data
fm <- nls(y ~ c3 + c2*(1/c0) * exp((-1/2)*(((x - c1)/c0) * ((x - c1)/c0)) ), start = list(c0 = 1, c1 = 10, c2 = 2, c3 = 1), algorithm = "port")
fm
plot(y ~ x, pch = 20)
lines(fitted(fm) ~ x, col = "red")




x <- station1_slug$Date_Time - station1_slug$Date_Time[1]
y <- station1_slug$Low_Range
# fit model to the data
fm <- nls(y ~ c3 + abs(c2)*(1/abs(c0)) * exp((-1/2)*(((x - c1)/abs(c0)) * ((x - c1)/abs(c0))) ), start = list(c0 = 1, c1 = station1_slug$Date_Time[length(station1_slug$Date_Time)/2], c2 = 100, c3 = 1))
fm
plot(y ~ x, pch = 20)
lines(fitted(fm) ~ x, col = "red")

      