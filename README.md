MathHelpRoom
============

This is a Shiny App used to track cadet attendance in the U.S. Coast Guard Academy's Mathematics Learning Center.

Installation
------------

This app is used on a stand alone workstation (no LAN/WAN connections), and its code is open source. The machine has R version 3.4.3 with the `shiny`, `shinyjs`, `shinythemes`, `lubridate`, and `openxlsx` packages and necessary dependencies installed as of 08JAN2018. The current installation utilizes Google Chrome to run the app, and R-Script that generates and dynamically updates the content starts the app via a desktop shortcut with the server process running in a minimized command prompt. The app is ready to run from within R-Studio provided the correct packages are currently installed.

1. Step 1: Copy Project Directory
Copy project directory into the appropriate location.

2. Step 2: Make Desktop Shortcut
Generate desktop shortcut, modifying the options to start minimized using below settings (modified for appropriat directory locations)

Shortcut Field: 
```"C:\Program Files\R\R-3.4.3\bin\x64\Rscript.exe" -e "source('C:/Users/Math/Documents/MathHelpRoom/Math Help Room Attendance/HelpRoom/MathHelpRoom.R')"```

Start In Field: 
```"C:\Users\Math\Documents\MathHelpRoom\Math Help Room Attendance\HelpRoom\"```

3. Step 3: Update Courses and Instructors for Current Term
Create updated instructor csv file using the instructors/instructors_S18.csv as a template. Note file name for updating the app.R and archiveData.R scripts.

4. Step 4: Update Excel Archive for Current Term
Create updated Math Help Room Excel Spreadsheet in the archive/ forlder using the .xlsx file provided as the template. Note file name for updating the app.R and archiveData.R scripts.

5. Step 5: Update Short Term Responses File
Create updated responses csv file using the responses/responsesSpring2018.csv as a template. Note that there is a row of field names and a single sample row of data. This sample row is required for the app to run correctly. Note the file name for updating the app.R and archiveData.R scripts.

6. Step 6: Update Application Scripts to work with Instructor and Excel Files
Update app.R and archiveData.R scripts with the file and directory names for responseFile, instructorsFile, and excelFile.

7. Step 7: Test Run from with R-Studio
Test run app from within R-Studio IDE by opening the app.R file and selecting the "Run App" command. Click on "Open in Browser" and verify that the available buttons in the app are Sign In and Download.

Usage
=====

Once the app is run once, it is no longer necessary to run from within the R-Studio IDE. Provided the shortcut is pointing to the currect file, it will generate a minimized Command Prompt and open Google Chrome to provide the user interface for the app. 

Signing In
----------

Cadets should press the sign in button which provides an interface to input their rank, first name, and last name. Combo boxes are provided to select a class and an instructor based on the data provided during setup. After completing sign-in the app returns to the home page.

Signing Out
-----------

If there are cadets currently signed in to the room, the home page will provide a button to allow them to sign out. It wil provide a list of all of the cadets currently signed in with checkboxes to select one or more cadets to sign out. The app will ask for a confirmation of the names of cadets selected, and will remove them from the room and log the departure time. When the room returns to a state with zero cadets, it will archive the recent sign-ins into the Excel file.

Download File
-------------

Clicking the Download button will provide a download handler to enable a user to export the archive xlsx workbook for saving to disk (notably an external drive). Be sure to add the .xlsx extension to the file name that you decide to use.

Troubleshooting
===============

If the screen is gray, the server process may have stopped. Close the Chrome Browser and the command prompt window, then re-click on the shortcut to restart the app.

Bug Reports
===========

Provide a description of the issue on the Github page, or email the maintainer, LCDR J. Harris (use .edu email address)