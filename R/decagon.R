require()

f = "./inst/extdata/decagon_ec5_BOB_ZERO 10Jul14-1435.xls"
df <- as.data.frame(read_excel(f, sheet = 1, skip = 3, col_names = c("DateTime", "VWC_1", "VWC_2", "VWC_3")))