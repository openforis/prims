library(dplyr)
library(ggplot2)

data <- data2[which(data2$STASIUN=="kecil2"), ]
data <- data2[which(data2$STASIUN=="kecil1"), ]
#data <- read.csv("sesame_sumsel.csv")
data <- data[which(data$GWL > -2), ]
gwlts <- ts(data$GWL, frequency=52560, start=c(2017,10))
smts <- ts(data$SOILMOISTURE, frequency=52560, start=c(2017,10))
raints <- ts(data$RAIN, frequency=52560, start=c(2017,10))

ts.plot((raints*10), (gwlts*100), smts, gpars = list(col = c("grey", "red", "blue"), ylim=c(-200,200)))

plot(cbind(raints, gwlts), yax.flip = TRUE)
ccf(raints, gwlts, ylab = "Cross-correlation")


daily_sum_precip <- data %>%
  mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
  group_by(day) %>% # group by the day column
  summarise(total_precip=sum(HUJAN)) %>%  # calculate the SUM of all precipitation that occurred on each day
  na.omit()

daily_avg_gwl <- data %>%
  mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
  group_by(day) %>% # group by the day column
  summarise(avg_gwl=mean(GWL)) %>%  # calculate the SUM of all precipitation that occurred on each day
  na.omit()

daily_avg_sm <- data %>%
  mutate(day = as.Date(WAKTU, format = "%m/%d/%Y %H:%M")) %>%
  group_by(day) %>% # group by the day column
  summarise(avg_sm=mean(SOILMOISTURE)) %>%  # calculate the SUM of all precipitation that occurred on each day
  na.omit()

ggplot(daily_sum_precip, aes(x = day, y = total_precip)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Daily Precipitation",
       subtitle = "Data plotted by year",
       y = "Daily precipitation (mm)",
       x = "Date") + theme_bw(base_size = 15)

ggplot(daily_avg_gwl, aes(x = day, y = avg_gwl)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Daily GWL",
       subtitle = "Data plotted by year",
       y = "Daily GWL (cm)",
       x = "Date") + theme_bw(base_size = 15)

ggplot(daily_avg_sm, aes(x = day, y = avg_sm)) +
  geom_point(color = "darkorchid4") +
  labs(title = "Daily SM",
       subtitle = "Data plotted by year",
       y = "Daily SM (cm)",
       x = "Date") + theme_bw(base_size = 15)

gwlts <- ts(daily_avg_gwl$avg_gwl, frequency=365, start=c(2017,1))
smts <- ts(daily_avg_sm$avg_sm, frequency=365, start=c(2017,1))
raints <- ts(daily_sum_precip$total_precip, frequency=365, start=c(2017,1))

ts.plot((raints*10), (gwlts*100), smts, gpars = list(col = c("grey", "red", "blue"), ylim=c(-200,500)))

