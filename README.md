ContactsDemo
============
A simple contacts application programming challenge for Solstice Mobile

## Overview
This application uses a API as a data source. This API is hosted and maintained by Solstice.

## Features
* Allows user to view all contacts
* Clicking on a contact loads the contacts details
* All images are loaded in background thread in order to give a good experience
* The Contact Detail page has some extra features
** Click to Call - Click on any of the phone numbers listed to immediately call
** Click to Email - Click on the email address of the contact to create an email 
** Click to Map - Quickly see a map of the contacts address
** View Website - Opens Safari and loads the contacts website
* Application is fully localized through a strings file
* Autolayout is used for all views. This means views layout correctly on all screen sizes from iPhone 4 up to iPad Air.
* All image assets are available in all needed scale resolutions.
* Launch Screen is done using a .xib which get's rid of the need for many different image assets. Drawback is that this means the application is iOS 8 only.

## To Do
* Unit Tests
** This is something I have not looked into much for iOS so I didn't want to waste time trying to get it all setup.
* Investigate Possible Memeory Leak
** When on the main table view controller, if the user keeps scrolling up and down I see the memory usage just keep increaseing. Not sure if this is a bug in the reuse of the table view cells or default functionality.
* Investigate Pause during Contacts API Call
** Sometimes there is a ~3 second pause when starting up the application. It seems to be hung up on the API call for contacts. Not sure if this is an issue in the code or just the API endpoint not responding quickly everytime.
* Content Store/Cache
** Should implement some kind of client side store or cache so the application can be used online.