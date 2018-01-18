#
# This script runs once daily to move help room daily cadets into the archive 
# Author: Jonathan Harris, LCDR, USCG
# Purpose: This application is used to track attendance at the U.S. Coast Guard
# Academy Mathematics Help Room.
# 
# Required directories: archive, responses
#
# Recommend that you update the responseFile path each 
# semester to reflect current staffing and class assignments

library("openxlsx")
library("lubridate")

# Define key directories and filenames
responsesDir <- "responses"
responseFile <- "responsesSpring2018.csv"
excelDir <- "archive"
excelFile <- "FY18 Math Help Room Attendance Log.xlsx"
wb.semester <- "SPRING"

# Initialize Workbook of Current Info
wb.file <- file.path(excelDir, excelFile)
wb <- loadWorkbook(wb.file)
getOption("openxlsx.dateFormat", "dd-mmm-yy")
archive <- read.xlsx(wb, sheet = wb.semester, 
                     #detectDates = TRUE, 
                     cols = 1:14,
                     skipEmptyCols = FALSE)
stylesheet <- which(getSheetNames(wb.file) == wb.semester)
nextrow <- ifelse(nrow(archive) == 0, 2, nrow(archive) + 1)
dateorigin <- getDateOrigin(file.path(excelDir, excelFile))
wb.styles <- getStyles(wb)
  
# Import the current responses data
datafile <- file.path(responsesDir, responseFile)
pastdata <- read.csv(datafile, as.is = TRUE)

# Check if data is available for archiving
if (nrow(pastdata) > 1) {
    
  pastdata <- cbind.data.frame(Page = "", pastdata)
  pastdata <- cbind.data.frame(pastdata, matrix(unlist(strsplit(pastdata$start_time, "-")), 
                                                byrow=TRUE, ncol=2), 
                               matrix(unlist(strsplit(pastdata$end_time, "-")), 
                                      byrow=TRUE, ncol=2), stringsAsFactors = FALSE)
  names(pastdata)[9:12] <- c("Date1", "Time In", "Date2", "Time Out")
  pastdata$Date <- ymd(pastdata$Date1)
  pastdata$`Time In` <- substr(pastdata$`Time In`, 1, 4)
  pastdata$`Time Out` <- substr(pastdata$`Time Out`, 1, 4)
  ind <- (nextrow + 1):(nextrow+nrow(pastdata)) - 2
  pastdata$rank <- substr(pastdata$rank, 1, 1)
  pastdata$lname <- toupper(pastdata$lname)
  pastdata$fname <- toupper(pastdata$fname)
  pastdata$X10 <- paste0("=TIME(LEFT(H", ind, ",2),RIGHT(H", ind, ",2),0)")
  pastdata$X11 <- paste0("=TIME(LEFT(I", ind, ",2),RIGHT(I", ind, ",2),0)")
  pastdata$X12 <- paste0("=K", ind, "-J", ind)
  pastdata$X13 <- paste0('=IF(L', ind, '=0,"0:05","0:00")')
  pastdata$X14 <- ""
  pastdata <- pastdata[, c("Page", "Date", "rank", "lname", "fname", "class", "instructor",
                           "Time In", "Time Out", "X10", "X11", "X12", "X13", "X14")]
  for (v in grep("X", names(pastdata), value = T)) {
    class(pastdata[[v]]) <- c(class(pastdata[[v]]), "formula")
  }
  names(pastdata) <- names(archive)
  
  
  # Style Mappings
  stylelist <- list(date = createStyle(halign = "center", valign = "center", numFmt = "dd-mmm-yy",
                                       border = "TopBottomLeftRight"),
                    text = createStyle(halign = "center", valign = "center", numFmt = "TEXT",
                                       border = "TopBottomLeftRight"),
                    hms = createStyle(halign = "center", valign = "center", numFmt = "hh:mm",
                                      border = "TopBottomLeftRight"))
  
  # Write new data into the workbook
  options("openxlsx.dateFormat" = "dd-mmm-yy")
  writeData(wb, sheet = wb.semester, x = pastdata[-1, -14], startRow = nextrow, colNames = FALSE,
            borders = "all")
  Map(function (x , y) writeFormula(wb, sheet = wb.semester, x = x, startCol = y, 
                                    startRow = nextrow),
      x = pastdata[-1, 10:13], y = 10:13)
  addStyle(wb, sheet = wb.semester, stylelist$date, 
           rows = 2:max(ind), #nextrow:(nextrow + nrow(pastdata) - 1), 
           cols = 2, gridExpand = TRUE)
  addStyle(wb, sheet = wb.semester, stylelist$text, 
           rows = 2:max(ind), #nextrow:(nextrow + nrow(pastdata) - 1), 
           cols = 3:9, gridExpand = TRUE)
  addStyle(wb, sheet = wb.semester, stylelist$hms, 
           rows = 2:max(ind), #nextrow:(nextrow + nrow(pastdata) - 1), 
           cols = 10:13, gridExpand = TRUE)
  
  saveWorkbook(wb, wb.file, overwrite = TRUE)
  if (!is.null(warnings())) stop("Suggested fix, close the xlsx file")
  # Clear the responses file
  cleardata <- read.csv(datafile, as.is = TRUE)[1, ]
  write.csv(cleardata, datafile, row.names = FALSE)
  cat(paste(Sys.time(), "Archived Data.\n"), 
      file = "log/logfile.txt",
      append = TRUE)
} else {
  cat("", file = "log/logfile.txt",
      append = TRUE)
}
