# Source file for MicroData Project 0.0.1
 
###### ONSET 

# HOBO style data loggers from ONSET
read.hobo <- function (f, sensor) { 
    
    if(missing(sensor)){
        
        warning("You need to specify which HOBO sensor these data are from. Sorry!")
    
    } else if(sensor == "pendant1"){
        
        # number of lines to skip
        lines_to_skip = 2
        
        # main import using data.table fread
        df <- data.table::fread(f, select = c(2:5), skip = lines_to_skip, col.names = c("DateTime", "Temp", "Intensity", "Voltage"))
        
        df <- as.data.frame(df)
        
        # format date column
        df$DateTime <- lubridate::mdy_hm(df$DateTime)
        return(df)
    
    } else if(sensor == "v2") {
    
    # number of lines to skip
    lines_to_skip = 2

    # main import using data.table fread
    df <- data.table::fread(f, select = c(2:4), skip = lines_to_skip, col.names = c("DateTime", "Temp", "RH"))
    
    df <- as.data.frame(df)
    
    # format date column
    df$DateTime <- lubridate::mdy_hms(df$DateTime)
    return(df)
    
    } else if(sensor == "tidbit") {
        
        # number of lines to skip
        lines_to_skip = 1
        
        # main import using data.table fread
        df <- data.table::fread(f, select = c(2:3), skip = lines_to_skip, col.names = c("DateTime", "Temp"))
        
        df <- as.data.frame(df)
        
        # format date column, not the the tidbit logger doesn't seem to log seconds
        df$DateTime <- lubridate::mdy_hm(df$DateTime)
        return(df)
        
    }
}

# light conversion for HOBO Pendant Loggers (use with caution)
hobo.h20.light <- function(x){
    
    # define constants from Long et al. 2012
    A1 = -8165.9
    t1 = 1776.4
    y0 = 8398.2
    
    par = A1 * exp( (x * -1) / t1) + y0
    
}



####### METER
read.meter <- function(f,  no_sensors){
    
    message("This script only works for the Decagon EM50 Logger and currently only for EC_5 sensors")
    # define colnames
    Cols1 = c("DateTime", "VWC_1")
    Cols2 = c("DateTime", "VWC_1", "VWC_2")
    Cols3 = c("DateTime", "VWC_1", "VWC_2", "VWC_3")
    Cols4 = c("DateTime", "VWC_1", "VWC_2", "VWC_3", "VWC_4")
    Cols5 = c("DateTime", "VWC_1", "VWC_2", "VWC_3", "VWC_4", "VWC_5")
    
    # need to define different loggers at some point
    
    if(missing(no_sensors)){
        
        stop("You need to specify how many sensors were in the logger. Sorry!")
        
    } else if(no_sensors == 1){
        
        # read in sheet
        # f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
        df <- read_excel(f, sheet = 1, skip = 3, col_names = Cols1, col_types = c("date", "numeric"))

    } else if(no_sensors == 2){
        
        # read in sheet
        # f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
        df <- read_excel(f, sheet = 1, skip = 3, col_names = Cols2, col_types = c("date", "numeric", "numeric"))

    } else if(no_sensors == 3){
        
        # read in sheet
        # f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
        df <- read_excel(f, sheet = 1, skip = 3, col_names = Cols3, col_types = c("date", "numeric", "numeric", "numeric"))

    } else if(no_sensors == 4){
        
        # read in sheet
        # f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
        df <- read_excel(f, sheet = 1, skip = 3, col_names = Cols4, col_types = c("date", "numeric", "numeric", "numeric", "numeric"))

    } else if(no_sensors == 5){
        
        # read in sheet
        # f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
        df <- read_excel(f, sheet = 1, skip = 3, col_names = Cols5, col_types = c("date", "numeric", "numeric", "numeric", "numeric", "numeric"))
    }


    # convert to data frame
    df <- as.data.frame(df)
    # # format date column
    # df$DateTime2 <- lubridate::ymd_hms(as.character(df$DateTime))
    # df$DateTime3 <- as_datetime(df$DateTime)
    return(df)
}




###### iButton/Thermochron
read.ibutton <- function(f){
    
    # number of lines to skip
    lines_to_skip = 8
    
    # main import using data.table fread
    df <- data.table::fread(f, skip = lines_to_skip, col.names = c("DateTime", "Temp"))
    
    df <- as.data.frame(df)
    
    # format date column
    df$DateTime <- lubridate::mdy_hm(df$DateTime)
    return(df)
}



###### TOMST 
### TMS3
read.tms3 <- function(f){
    message("For TOMST TMS3 data, the temperature sensors are enumerated from above ground (i.e., Temp3) to the deepest sensor below ground (i.e., Temp1). For more info see:  https://tomst.com/web/en/systems/tms/unit-architecture/")
    
    df <- data.table::fread(f, skip = 0, col.names = c("Index", "DateTime", "TimeZone", "Temp3", "Temp2", "Temp1", "SoilWater", "Shake", "ErrorFlag"))  
    # convert to data frame
    df <- as.data.frame(df)
        
    # return data frame
    return(df)
    # message("For TOMST TMS3 data, the temperature sensors are enumerated from above ground (i.e., Temp3) to the 
    #             deepest sensor below ground (i.e., Temp1). For more info see:  https://tomst.com/web/en/systems/tms/unit-architecture/")
                
}

###### Convert raw TMS3 moisture data to VWC
tms3.vwc <- function(df, soil.type){
    
    # get that case just right
    soil.type <- tolower(soil.type)
    
    # create dummy soil column
    df$soil.type <- soil.type
    # use tidyr mutate to change
    df %>%
        dplyr::mutate(VWC = dplyr::case_when(soil.type == "sand" ~ (-0.000000003 * SoilWater^2) +	(0.000161 * SoilWater) - 0.11,
                                             soil.type == "loamy sand a" ~ (-0.000000019 * SoilWater^2) +	(0.000266 * SoilWater) - 0.154,
                                             soil.type == "loamy sand b" ~ (-0.000000023 * SoilWater^2) +	(0.000282 * SoilWater) - 0.167,
                                             soil.type == "sandy loam a" ~ (-0.000000038 * SoilWater^2) +	(0.000339 * SoilWater) - 0.215,
                                             soil.type == "sandy loam b" ~ (-0.0000000009 * SoilWater^2) +	(0.000262 * SoilWater) - 0.159,
                                             soil.type == "loam" ~ (-0.000000051 * SoilWater^2) +	(0.000398 * SoilWater) -0.291,
                                             soil.type == "silt loam" ~ (-0.000000017 * SoilWater^2) +	(0.000118 * SoilWater) - 0.101,
                                             soil.type == "peat" ~ (-0.000000123 * SoilWater^2) +	(-0.000145 * SoilWater) - 0.203)) %>%
        data.frame() -> df

    # remove column
    df <- select(df, -c("soil.type"))
    
    # return
    return(df)
    
}


tomst.soils(x) <- function{
    soils <- read.csv("./inst/extdata/TMS3_VWC_calibration_table.csv")
    print(soils)
    }
###### other dependencies and utilities
#extrafont::loadfonts(device = "win")

# CUSTOM THEMES
##### CUSTOM PLOT THEME
try_theme <- function() {
    theme(
        # add border 1)
        panel.border = element_rect(colour = "black", fill = NA, size = 0.5),
        # color background 2)
        #panel.background = element_rect(fill = "white"),
        # modify grid 3)
        panel.grid.major.x = element_line(colour = "#333333", linetype = 3, size = 0.5),
        panel.grid.minor.x = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
        panel.grid.major.y = element_line(colour = "#333333", linetype = 3, size = 0.5),
        panel.grid.minor.y = element_line(colour = "darkgrey", linetype = 3, size = 0.5),
        # modify text, axis and colour 4) and 5)
        axis.text = element_text(size = 10, colour = "black", family = "Times New Roman"),
        axis.title = element_text(size = 12, colour = "black", family = "Times New Roman"),
        axis.ticks = element_line(colour = "black"),
        axis.ticks.length=unit(-0.1, "cm"),
        # legend at the bottom 6)
        legend.position = "bottom",
        strip.text.x = element_text(size=10, color="black",  family = "Times New Roman"),
        strip.text.y = element_text(size=10, color="black",  family = "Times New Roman"),
        strip.background = element_blank()
    )
}