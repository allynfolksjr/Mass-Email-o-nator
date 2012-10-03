# NikkyMail

Nikky Southerland  
University of Washington Information Technology  
nikky@cac.washington.edu  

# Version History

## 1.0.1

* Fix bug that impacted shared NetID check

## 1.0.0

* Moved all configuration variables to sample configuration file

## 0.1.0

*Initial Release*

# Introduction

NikkyMail is very much a script that started with a) a desire to learn Ruby to replace Perl as a general-purpose scripting language and b) a need for a better script to email users about various things. It began as a very simple program and has since evolved in a somewhat haphazard manner.

# Key Features

* Accepts CSV data files as input
* Passes message handling to a user-defined block for custom manupliation using the CSV-supplied data or other information.
* Robust logging
* Default email domain: if an address doesn't have a domain, automatically use user-defined domain and append to the end of user.


# UW Integration

NikkyMail also works closely with UW-related projects and notifications, and supports the following:

* Ability to check for a Shared NetID with administrators, and CC them in the notification message.

# Quick Start Guide

1. Copy `configuration.sample.rb` to `configuration.rb`
2. Populate a file named "users" with your destination addresses, one per line. 
3. Put your message in a file named "message"
4. Change any settings desired in `configuration.rb`
5. Run `configuration.rb` and let it do its thing.

# Full documentation

The configuration file has most of the information that is required to customize this script, however, there are a few relevant points that should be mentioned and discussed in further details.

## User File Processing

The user file is actually read as a CSV file, which enables you to add your own data into the script. data[0] is assumed to be the destination address(es), but the rest are ignored unless explictly referenced in the message processing block, as outlined below. One possible use of this is a file that has some octal permission in data[1] field, and then the message processing block will have a custom blurb for each possible combination.

## Message Processing

If the symbol `:message_parse_block` is defined in the configuration file, this block will be run evey time an email is parsed. This makes the most sense when combined with the user file processing, as outlined above.

## UW Groups Web Service Integration

In order for the groups web service check work properly, you must have a UWCA-created certificate and key.



# Caveats, To-do Etc.

* Needs a very large rewrite.
* CLI interface.
* Configuration is poorly handled and even more poorly understood.
* Store all message objects in one big array and then only send if the entire run looks good.
* Error handling.

# Bugs

* Shared NetIDs may not have administrators, and only contain one owner. GWS will not recognize this as requiring a group for authentication purposes, and the shared NetID administrator check will pull up no notices. This mostly impacts older NetIDs.
