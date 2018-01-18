#
# This is a Shiny web application. 
# Author: Jonathan Harris, LCDR, USCG
# Purpose: This application is used to track attendance at the U.S. Coast Guard
# Academy Mathematics Help Room.
# 
# Required directories: responses, instructors
#
# Recommend that you update the responseFile and instructorsFile path each 
# semester to reflect current staffing and class assignments

# if (!require("shiny")) install.packages("shiny")
# if (!require("shinyjs")) install.packages("shinyjs")
# if (!require("shinythemes")) install.packages("shinythemes")

library(shiny)
library(shinyjs)
library(shinythemes)

# Write Start Message to Log File
cat(paste(Sys.time(), "Started App.\n"), 
    file = "log/logfile.txt",
    append = TRUE)

# Define key directories and filenames
responsesDir <- "responses"
responseFile <- "responsesSpring2018.csv"
instructorDir <- "instructors"
instructorsFile <- "instructors_S18.csv"
excelDir <- "archive"
excelFile <- "FY18 Math Help Room Attendance Log.xlsx"

# Load Instructor list
inst <- read.csv(file.path(instructorDir, instructorsFile),
           header = TRUE,
           as.is = TRUE)

# Load Required Fields:
fieldsAll <- names(read.csv(
    file.path(responsesDir, responseFile),
    header = TRUE,
    as.is = TRUE
  ))

# Define Mandatory Fields
fieldsMandatory <- c("rank", "fname", "lname")

# Identify Mandatory Field labeling function
labelMandatory <- function (label) {
  tagList(label, span("*", class = "mandatory_star"))
}

# Apply CSS for the app:
appCSS <- ".mandatory_star { color: red; }"

# Get Data function
getData <- function() {
  datafile <- file.path(responsesDir, responseFile)
  pastdata <- read.csv(datafile, as.is = TRUE)
  pastdata
}

# Define timestamp function
humanTime <- function() format(Sys.time(), "%Y%m%d-%H%M%OS")

# Data Saving function
saveData <- function (data) {
  write.table(x = data, file = file.path(responsesDir, responseFile),
              sep = ",", row.names = FALSE, quote = TRUE)
}

# Generate List of Signed-In Students
stillHere <- function() {
  datafile <- file.path(responsesDir, responseFile)
  pastdata <- read.csv(datafile, as.is = TRUE)
  pastdata <- pastdata[is.na(pastdata$end_time), c(1:3, 6)]
  id <- pastdata[, 4]
  pastdata <- pastdata[, 1:3]
  pastdata <- apply(pastdata, 1, paste, collapse = " ")
  out <- list(name = pastdata, id = id)
  names(out$id) <- names(out$name)
  out
}

# Drop Down list helper functions cN for cadet name, cV for index value
cN <- function () {
  if (length(stillHere()$name > 0)) {
    out <- unname(stillHere()$name)
  } else {
    out <- NA
  }
  out
}

cV <- function () {
  if (length(stillHere()$name > 0)) {
    out <- names(stillHere()$name)
  } else {
    out <- NA
  }
  out
}

# Function to check if any cadets are in the room, i.e. not signed out
inRoom <- function () {
  if (!(all(is.na(cN())))) {
    shinyjs::show("signout")
    shinyjs::reset("out_list")
  } else {
    shinyjs::hide("signout")
    # Added 9JAN18
    source("archiveData.R")  
  }
}

# CheckBoxGroup update helper function
updateCB <- function (session) {
  updateCheckboxGroupInput(session, "out_list", "Select Names to Depart",
                           #choices = ifelse(is.na(cN()), "None", cN()),
                            choiceNames = ifelse(is.na(cN()), "None", cN()),
                            choiceValues = ifelse(is.na(cV()), "None", cV()))
}

################################################################################
#                            USER INTERFACE SECTION                            #
################################################################################

# Define UI for Application
ui <- fluidPage(
  shinyjs::useShinyjs(),
  shinyjs::inlineCSS(appCSS),
  theme = shinythemes::shinytheme("cosmo"),
  
  # Application title
  titlePanel(title="USCGA Mathematics Learning Center Attendance Tracker"),
  
  tags$head(
    tags$link(
      rel = "icon", 
      type = "image/x-icon", 
      href = "http://localhost:1984/default.ico")
  )
  ,
  
  # Home Page (In Out or Download Data)
  div(
    id = "in_or_out",
    actionButton("signin", "Sign In", class = "btn-primary"),
    actionButton("signout", "Sign Out", class = "btn-secondary"),
    downloadButton("download", "Download Spreadsheet", class = "btn-secondary")
  ),
  
  # Sign-In Form
  shinyjs::hidden(
    div(
      id = "form",
      selectInput("rank", labelMandatory("Rank"), c("4/c", "3/c", "2/c", "1/c")),
      textInput("fname", labelMandatory("First Name")),
      textInput("lname", labelMandatory("Last Name")),
      selectInput("class", "Class", sort(unique(inst$Course.Name))),
      selectInput("instructor", "Instructor", sort(unique(inst$Name))),
      actionButton("submit", "Submit", class = "btn-primary")
    )
  ),
  
  # Submission Confirmation
  shinyjs::hidden(
    div(
      id = "thankyou_msg",
      h3("Thanks, your submission has been recorded!"),
      actionButton("b2m", "Back to Main Menu")
    )),
  
  # Sign Out Form
  shinyjs::hidden(
    div(
      id = "sign_out_form",
      checkboxGroupInput(
        "out_list",
        "Select Names to Depart",
        #choices = cN(),
        choiceNames = ifelse(is.na(cN()), "None", cN()),
        choiceValues = ifelse(is.na(cV()), "None", cV())
      ),
      actionButton("check_choices", "Sign Out", class = "btn-primary")
    )),
  
  # Sign Out Confirmation
  shinyjs::hidden(
    div(
      id = "sign_out_confirm",
      verbatimTextOutput("out_names"),
      actionButton("final_sign_out", "Confirm Sign Out", class = "btn-primary"),
      actionButton("cancel_btn", "Cancel", class = "btn-secondary")
    )
  )
)



################################################################################
#                         SERVER SUBROUTINE SECTION                            #
################################################################################


# Server File
server <- function(input, output, session) {
  
  # Reactive Processes
  formData <- reactive({
    datafile <- file.path(responsesDir, responseFile)
    pastdata <- read.csv(datafile, as.is = TRUE)
    data <- sapply(fieldsAll[1:5], function(x)
      input[[x]])
    data <- c(data, timestamp = humanTime(), NA)
    data <- rbind(pastdata, data)
    data
  })
  
  exitData <- reactive({
    datafile <- file.path(responsesDir, responseFile)
    pastdata <- read.csv(datafile, as.is = TRUE)
    
    ind <- stillHere()$id[paste(input$out_list)]   # Works with the new groupCheckBoxInput
    pastdata[pastdata$start_time %in% ind, "end_time"] <-
      humanTime()
    cat(paste(Sys.time(), "Signed Out ", length(ind), "cadets.\n"), 
        file = "log/logfile.txt",
        append = TRUE)
    pastdata
  })
  
  # Submit Enabling Based on the mandatory fields
  observe({
    inRoom()
    
    # check if mandatory fields have a value
    mandatoryFilled <- vapply(fieldsMandatory, function(x) {
      !is.null(input[[x]]) && input[[x]] != ""
    }, logical(1))
    mandatoryFilled <- all(mandatoryFilled)
    
    # Enable/disable the submit button based on mandatory condition
    shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
  })
  
  # Action to take when sign-in button is pressed
  observeEvent(input$signin, {
    shinyjs::hide("in_or_out")
    shinyjs::show("form")
  })
  
  # Action to take when sign-out button is pressed
  observeEvent(input$signout, {
    shinyjs::hide("in_or_out")
    shinyjs::show("sign_out_form")
    shinyjs::reset("out_list")
    updateCB(session)
  })
  
  # Action to take when submit button is pressed
  observeEvent(input$submit, {
    saveData(formData())
    shinyjs::reset("form")
    shinyjs::hide("form")
    shinyjs::show("thankyou_msg")
  })
  
  # Action to take when check choices signout button is pressed
  observeEvent(input$check_choices, {
    shinyjs::show("sign_out_confirm")
    output$out_names <- renderText({
      exitlist <- paste(stillHere()$name[input$out_list], collapse = ", ")
      paste("Are you sure you want the following individuals to Exit:",
            exitlist,
            sep = "\n")
    })
  })
  
  # Action to take when sign out confirm button is pressed
  observeEvent(input$final_sign_out, {
    saveData(exitData())
    shinyjs::reset("sign_out_form")
    shinyjs::reset("out_list")
    updateCB(session)
    shinyjs::hide("sign_out_form")
    shinyjs::hide("sign_out_confirm")
    shinyjs::show("thankyou_msg")
  })
  
  # Action to take when cancel button is pressed
  observeEvent(input$cancel_btn, {
    shinyjs::show("in_or_out")
    shinyjs::reset("sign_out_form")
    shinyjs::hide("sign_out_form")
    shinyjs::hide("sign_out_confirm")
    shinyjs::hide("thankyou_msg")
  })
  
  # Action to take when switching back to main form
  observeEvent(input$b2m, {
    inRoom()
    shinyjs::hide("thankyou_msg")
    shinyjs::show("in_or_out")
    shinyjs::reset("in_or_out")
    shinyjs::reset("out_list")
  })
  
  # Action to take when opting to download sign-in data
  output$download <- downloadHandler(
    filename = paste0(humanTime(), " - ", excelFile), 
    # filename = "temp.csv",
    # content = function(file) {
    #   pastdata <- getData()
    #   write.csv(pastdata, file, row.names = FALSE)
    # },
    content = function (file) file.copy(file.path(excelDir, excelFile), file)#,
    #contentType = "text/csv"
  )
  
  # Exit on Close
  
  session$onSessionEnded({
    cat(paste(Sys.time(), "Stopped App.\n"), 
        file = "log/logfile.txt",
        append = TRUE)
    stopApp
    })

}

# Run the application
shinyApp(ui = ui, server = server)
