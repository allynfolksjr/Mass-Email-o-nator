require_relative 'mailer3'
# This configuration is full of relics. Just life with it I guess?
configuration = {
  domain: 'example.com', # Domain to be used if the file list just has users, ignored for full addresses
  from: 'Test McTest <test@example.com>', # From variable
  subject: 'Subject of all Subjects', # Subject of message
  project_name: 'file', # Don't change this
  message_file: 'message', # Or this
  file: 'users', # Or this
  via: :sendmail, # Change to :smtp if you need it
  #debug: 1, # Uncommented, it will write message body to file instead of sending them.
  sleep: 2, # Time in seconds to sleep between messages
}

# This is all the actual program work. Just ignore it and let it do its thing.
file = File.open(configuration[:message_file],'r')
message = file.read
message_parse_block = Proc.new { |data| temp_message = message.dup
temp_message.gsub!(/&&NETID&&/,data[0])
temp_message}

spam = Mailing.new(configuration,message_parse_block||=nil)
spam.shared_netid_check = false 
spam.send_message

