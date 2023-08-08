source("./R/source.R")

library(data.table)
library(lubridate)
library(viridis)
library(ggplot2)
library(gridExtra)
library(cowplot)
library(scales)
library(readxl)
library(dplyr)
library(RColorBrewer)

theme_strip <- theme_minimal()+
    theme(axis.text.y = element_blank(),
          axis.line.y = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          legend.title = element_blank(),
          axis.text.x = element_text(vjust = 3),
          panel.grid.minor = element_blank(),
          plot.title = element_text(size = 14, face = "bold")
    )


col_strip <- brewer.pal(11, "RdBu")

brewer.pal.info

          

# import data
# define file
f = "./inst/extdata/hobo_pro_v2.csv"

#
df <- read.hobo(f, sensor = "v2")


# find max value per day

#Sample data set


df %>%
    select(c(DateTime, Temp)) %>%
    mutate(Date = as.Date(DateTime, na.rm = TRUE)) %>%
    group_by(Date) %>%
    dplyr::filter(Temp == max(Temp, na.rm = TRUE)) %>%
    distinct(Temp, .keep_all = T) %>%
    ungroup() %>%
    data.frame() -> df.day

# plot
x11(width = 10, height = 2)
ggplot(df.day, aes(x = Date, y = 1, fill = Temp))+
    geom_tile()+
    scale_x_date(date_breaks = "3 days",
                 date_labels = "%D",
                 expand = c(0, 0))+
    scale_y_continuous(expand = c(0, 0))+
    scale_fill_gradientn(colors = rev(col_strip))+
    guides(fill = guide_colorbar(barwidth = 1))+
    labs(title = "Woolen Mills, Daily Max Temperature 2023",
         caption = "HOBO V2 Temp/RH Sensor")+
    theme_strip

x11(width = 3, height = 2)
ggplot(df.day, aes(x = Date, y = 1, fill = Temp))+
    geom_tile(show.legend = FALSE)+
    scale_x_date(date_breaks = "1 day",
                 date_labels = "%D",
                 expand = c(0, 0))+
    scale_y_continuous(expand = c(0, 0))+
    scale_fill_gradientn(colors = rev(col_strip))+
    theme_void()


# make sequence of days
z <- seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by="days")
y1 <- rnorm(100, mean = 15, sd = 1)
y2 <- rnorm(165, mean = 20, sd = 1.5)
y3 <- rnorm(100, mean = 15, sd = 1)

y = c(y1, y2, y3)

x <- data.frame(z, y)

x11(width = 10, height = 2)
ggplot(x, aes(x = z, y = 1, fill = y))+
    geom_tile(show.legend = FALSE)+
    scale_x_date(date_breaks = "1 day",
                 date_labels = "%D",
                 expand = c(0, 0))+
    scale_y_continuous(expand = c(0, 0))+
    scale_fill_gradientn(colors = rev(col_strip))+
    theme_void()

