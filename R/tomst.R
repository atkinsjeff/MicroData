# TOMST
# https://tomst.com/web/en/systems/tms/data/
# 
# Binary file is memory image of the device, relevant data you can find in the data file. The name of the file contain device serial number, for example data_93130131_0.csv are from unit with number 93130131 (serial number is engraved on the top of the device)

Thermometers are placed from top in this order T3,T2,T1 (see picture) 
Following is single sample line from file *data*.csv

0;31.10.2013 11:45;0;21.5625;22.0625;23.125;148;1;0

0	index of the measure
31.10.2013 11:45	date and time in UTC
0	time zone
21.5625	T1
22.0625	T2
23.125	T3
148	soil moisture count (raw moisture data)
1	shake
0	errFlag (if =1 the device couldn’t convert time from PCF chip)
All measurement runs in UTC, please use time zone parameter for 
recalculation to the local time. There is shake sensor placed on the device, values can be only 1 (shake) or 0.

# url to calibration coeff for soil moistuer : https://tomst.com/web/wp-content/uploads/Doc/Calibration-set-TMS3.pdf
# Calibration set for typical soils


# Sand 
# y = -0.000000003x2
+ 0.000161192x - 0.109956505
R
2
= 0.998123954

f <- "./inst/extdata/data_ExampleTMS3.csv"
# read TOMSt

tom <- data.table::fread(f, skip = 0, col.names = c("Index", "DateTime", "TimeZone", "Temp3", "Temp2", "Temp1", "SoilWater",
                                             "Shake", "ErrorFlag"))


# number of lines to skip
lines_to_skip = 2

# main import using data.table fread
df <- data.table::fread(f, select = c(2:4), skip = lines_to_skip, col.names = c("DateTime", "Temp", "RH"))

df <- as.data.frame(df)

# format date column
df$DateTime <- lubridate::mdy_hms(df$DateTime)

xx <- read.tms3(f)

