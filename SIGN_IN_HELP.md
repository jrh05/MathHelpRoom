# Math Learning Center Attendance Tracker Application

Usage
=====

Welcome to the help page for the Mathematics Learning Center Sign-In App. This app is accessed using Google Chrome, but requires you to click the shortcut to start the App since this computer is not connected to any network. If Chrome is open but you cannot find the sign in app, close all windows on the workstation and double click on the Sign In shortcut in the center of the screen. This will generate a minimized Command Prompt and open Google Chrome to provide the user interface for the app. The webaddress in Chrome will be http://127.0.0.1:XXXX with the XXXX being a random port number.

Signing In
----------

Cadets should press the sign in button which provides an interface to input their rank, first name, and last name. Combo boxes are provided to select a class and an instructor based on the data provided during setup. After completing sign-in the app returns to the home page.

Signing Out
-----------

If there are cadets currently signed in to the room, the home page will provide a button to allow them to sign out. It will provide a list of all of the cadets currently signed in with checkboxes to select one or more cadets to sign out. The app will ask for a confirmation of the names of cadets selected, and will remove them from the room and log the departure time. When the room returns to a state with zero cadets, it will archive the recent sign-ins into the Excel file.

Download File
-------------

Clicking the Download button will provide a download handler to enable a user to export the archive xlsx workbook for saving to disk (notably an external drive). Be sure to add the .xlsx extension to the file name that you decide to use.

Troubleshooting
===============

If the Google Chrome screen is gray, the server process may have stopped. Close the Chrome Browser and the command prompt window, then re-click on the shortcut to restart the app.

Bug Reports
===========

Provide a description of the issue on the Github page, or email the maintainer, LCDR J. Harris (please use the .edu email address)
