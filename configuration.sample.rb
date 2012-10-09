
# Require the mailer library

require_relative 'mailer3'

## This hash initializes all options for the script.
#
# Required: domain, from, subject
# Optional: message_file, file, via, debug, sleep

configuration = {

  ## Required variables

  # Domain is appended to the end of any user in the user file that does not
  # have a domain already. For example, "bob" would be changed to
  # "bob@example.com". Full email addresses in the user file are *not* modified
  domain: 'example.com',

  # This is where the message is sent from.
  from: 'Test McTest <test@example.com>',

  # Subject of the message
  subject: 'Subject of all Subjects',

  ## Optional Variables

  # Uncomment following line to add owners/administrators of shared NetID as cc's
  shared: 1,

  # If connecting to the UW groups web service, provide the location to your
  # cert and key
  cert: '/home/nikky/nikky_cac_washington_edu.cert',
  key: '/home/nikky/nikky_cac_washington_edu.key',

  # The UA locations
  #cert: '/etc/ssl/certs/ldapmgmt.cac.washington.edu.cert',
  #key: '/etc/ssl/certs/ldapmgmt.cac.washington.edu.key',

  # Default location for the message file: "./message." Uncomment out and modify
  # to override.
  #message_file: 'message',

  # Default location for the file of email addresses to send to. Uncomment out
  # to modify and override. User file format is one per line, with optional
  # csv format for custom data schemes.
  #user_file: 'users',

  # Blacklist. Put in users to be ignored (blacklisted). Useful when you 
  # have multiple mailings and don't want to edit the user list manually
  # each time. Default is 'blacklist'
  # blacklist: 'blacklist',


  # The pony library has two main methods of sending messages, via sendmail,
  # which is the default, or smtp via localhost. Change to :smtp if required.
  #via: :sendmail,

  # Debug, when set, will display more information, not send actual messages,
  # and writes to a test log rather than production.
  debug: 1,


  # Time to sleep between sending messages. Default is 2 seconds.
  #sleep: 2,


  # This is a really important one, for reals. When present, this block is called
  # immediately before an individual email body is sent out, and you can use it
  # to do any sort of required subsitution or other program logic. The data
  # variable should be explained

  # * data[]
  # data contains the contents of the users file. data[0] is the email address
  # data[(1...)] contains other fields in the data file as outlined by the CSV
  # format, so you can place other information there as required, such as
  # permissions to be parsed or additional instructions.
  #
  #

  message_parse_block: lambda do |data,message|
    temp_message = message.dup
    temp_message.gsub!(/&&NETID&&/,data[0])
    temp_message
  end
}

spam = Mailing.new(configuration)
spam.send_message
