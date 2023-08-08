# Fonts Script#Install extrafont from CRAN will automatically install extrafontdb and Rttf2pt1:
install.packages('extrafont')
library(extrafont)

#need to do this everytime a new true font type file is installed on pc
# this is ones you load already
font_import(paths = "C:/Users/jeffa/AppData/Local/Microsoft/Windows/Fonts")

# this is for ones stored on your computer base
font_import(paths = "C:/Windows/Fonts")