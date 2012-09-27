# NikkyMail

Nikky Southerland
University of Washington Information Technology
nikky@cac.washington.edu

# Version History

## 0.1.0

*Initial Release*

# Introduction

NikkyMail is very much a script that started with a) a desire to learn Ruby and b) a need for a better script to email users about various things. It began as a very simple program and has since evolved in a highly haphazard and rushed manner to include many more poorly-documented and understood features. I wouldn't recommend anyone using it.

# Key Features

* Accepts CSV data files as input
* Passes message handling to a user-defined block for custom manupliation using the CSV-supplied data or other information.
* Robust logging
* Default email domain: if an address doesn't have a domain, automatically use user-defined domain and append to the end of user.

# UW Integration

NikkyMail also works closely with UW-related projects and notifications, and supports the following:

* Ability to check for a Shared NetID with administrators, and CC them in the notification message.

# Caveats, To-do Etc.

* Needs a very large rewrite.
* CLI interface.
* Configuration is poorly handled and even more poorly understood.

# Bugs

* Shared NetIDs may not have administrators, and only contain one owner. GWS will not recognize this as requiring a group for authentication purposes, and the shared NetID administrator check will pull up no notices. This mostly impacts older NetIDs.
