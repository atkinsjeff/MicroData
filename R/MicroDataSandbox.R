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



########### FILE IMPORT
# "v2" example for the HOBO V2 Temperature and RH logger
# define file
f = "./inst/extdata/hobo_pro_v2.csv"

#
df <- read.hobo(f, sensor = "v2")


########### Graphing Parameters
# Custom labels for all plots, long format
TempLabel = expression(paste("Air Temperature [ ", degree,"C ]"))
RHLabel = "Relative Humidity [%]"
LightLabel = expression(paste(Light~Intensity~"["~Lumens~ft^2~"]"))

# Custom labels for plots, science formatted
TempLabelSci = expression(paste("T"[Air]~" (", degree,"C)"))
RHLabelSci = "RH (%)"
LightLabelSci = expression(paste(I~"("~Lumens~ft^2~")"))
VWCLabelSci = expression(paste(theta~"("~m^-3~m^-3~")"))

# create a custom palette
# VCU colors with white removed
VCUColors <- c("#F8B300", "#000000",  "#333333", "#444444", "#555555")
DigitalNeutral <- c("#E57200", "#FFCE00",  "#00B3BE", "#856822", "#275E37", "#B2E0D6", "#E5CBB1", "#CCDBAE")



# LONG TIME SERIES
# Link for more information on axis modification for dates, times, and date times:
# https://bookdown.org/Maxine/ggplot2-maps/posts/2019-11-27-using-scales-package-to-modify-ggplot2-scale/

# the x11() call creates a popup window with the plot

# here is a temperature graph where there are differences in how the dates are handled on the x axis
# here abbreviated month and day e.g. Mar-21
x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    try_theme()+
    scale_x_datetime(date_labels = "%b-%d", breaks = breaks_width("3 days"))

# here full month e.g., March 21
x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))

# with different themes

# theme classic
x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    theme_classic()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))

x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    theme_bw()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))

x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    theme_light()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))

x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabel)+
    theme_minimal()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))





### making a multiplot
p.Temp <- ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabelSci)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("3 days"))

p.RH <- ggplot(df, aes(x = DateTime, y = RH))+
    geom_line(color = "#F84C1E")+
    xlab("")+
    ylab(RHLabelSci)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("3 days"))

# using cowplot
# arrange two plots into one column and making it wide. 
x11(width = 8, height = 4)
plot_grid(
    p.Temp, p.RH,
    labels = "AUTO", # automatically writes in labels, e.g., A, B
    align = "v", # aligns the axis on the left
    ncol = 1         # this call specifically stacks them
)


#### Say we want to double plot these
# this is modified from:  https://finchstudio.io/blog/ggplot-dual-y-axes/

max_first  <- max(df$Temp, na.rm = TRUE)   # Specify max of first y axis
max_second <- max(df$RH, na.rm = TRUE) # Specify max of second y axis
min_first  <- min(df$Temp, na.rm = TRUE)   # Specify min of first y axis
min_second <- min(df$RH, na.rm = TRUE) # Specify min of second y axis

# scale and shift variables calculated based on desired mins and maxes
scale = (max_second - min_second)/(max_first - min_first)
shift = min_first - min_second

# Function to scale secondary axis
scale_function <- function(x, scale, shift){
    return ((x)*scale - shift)
}

# Function to scale secondary variable values
inv_scale_function <- function(x, scale, shift){
    return ((x + shift)/scale)
}

# pkpd <- ggplot(res, aes(x = time, y = CP)) +
#     geom_line(aes(color = "Drug Concentration")) +
#     geom_line(aes(y = inv_scale_function(RESP, scale, shift), color = "Biomarker (IU/mL")) +
#     scale_x_continuous(breaks = seq(0, 336, 24)) +
#     scale_y_continuous(limits = c(min_first, max_first), sec.axis = sec_axis(~scale_function(., scale, shift), name="Biomarker (IU/mL)")) +
#     labs(x = "Time (hr)", y = "Concentration (mg/L)", color = "") +
#     scale_color_manual(values = c("orange2", "gray30"))

x11(width = 8, height = 3)
ggplot(df, aes(x = DateTime, y = Temp)) +
    geom_line(aes(color = "Air Temperature")) +
    geom_line(aes(y = inv_scale_function(RH, scale, shift), color = RHLabelSci)) +
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("3 days"))+
    scale_y_continuous(limits = c(min_first, max_first), 
                       sec.axis = sec_axis(~scale_function(., scale, shift), name="RH (%)")) +
    labs(x = "", y = TempLabelSci, color = "") +
    scale_color_manual(values = c("#232D4B", "#F84C1E"))+
    try_theme()+
    theme(legend.position = "bottom")






###### MULTIPLE LOGGERS ON SAME PLOT EXAMPLE WITH DECAGON VWC Data
f <- "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"

df <- read.meter(f, no_sensors = 3)

# this code reformats the data to tidy and assigns the depth of the sensor
# we can adjust the ingestion code to account for that as a data string too which
# I would like to do but this works for now.

# changes colnames to depths from the data (5, 20, and 50 cm depths)
colnames(df) <- c("DateTime", "Five", "Twenty", "Fifty")

# makes tidy format long
df %>%
    tidyr::pivot_longer(
        cols = Five:Fifty,
        names_to = c("Depth"),
        values_to = "VWC") %>%
    data.frame() -> df.long


# multi plot
x11(width = 8, height = 3)
ggplot(df.long, aes(x = DateTime, y = VWC, color = Depth))+
    geom_line(linewidth = 1)+
    xlab("")+
    ylab(VWCLabelSci)+
    scale_color_manual(values = DigitalNeutral)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("5 days"))
    



#########################################
# PENDANT LOGGERS
# # "pendant1" example for a HOBO pendant temperature and light logger
f = "./inst/extdata/hobo_pendant_HC_6-10-10.csv"

# call the read.hobo function
df <- read.hobo(f, sensor = "pendant1")

p.Temp <- ggplot(df, aes(x = DateTime, y = Temp))+
    geom_line(color = "#232D4B")+
    xlab("")+
    ylab(TempLabelSci)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("3 days"))

p.Light <- ggplot(df, aes(x = DateTime, y = Intensity))+
    geom_line(color = "#F84C1E")+
    xlab("")+
    ylab(LightLabelSci)+
    try_theme()+
    scale_x_datetime(date_labels = "%B %d", breaks = breaks_width("3 days"))

# using cowplot
# arrange two plots into one column and making it wide. 
x11(width = 8, height = 4)
plot_grid(
    p.Temp, p.Light,
    labels = "AUTO",  # automatically writes in labels, e.g., A, B
    align = "v", # aligns axis on the left
    ncol = 1         # this call specifically stacks them
)


