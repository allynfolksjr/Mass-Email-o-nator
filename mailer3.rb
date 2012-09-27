require 'csv'
require 'pony'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'yell'

class Message
  public

  # Every message requires at least the first four variables.
  def initialize(subject,from,to,body,cc=nil,bcc=nil,via=:sendmail)
    @subject = subject
    @from = from
    @to = to
    @body = body
    @via = via
    @cc = cc
    @bcc = bcc
  end

  # Invoke error checking and send message.
  def send_message
    error_check
    if $debug
      #puts "\n\n<=> Debug Mode <=>"
      #puts "Via: #{@via}"
      #puts "From: #{@from}"
      #puts "To: #{@to}"
      #puts "Cc: #{@cc}" unless @cc.nil?
      #puts "Bcc: #{@bcc}" unless @bcc.nil?
      #puts "Subject: #{@subject}\n\n"
      #puts @body
    else
      Pony.mail(
        to: @to,
        from: @from,
        subject: @subject,
        body: @body,
        cc: @cc,
        bcc: @bcc,
        via: @via,
        headers: { "mailer" => "nikkyMail" }
      )
      sleep 2
    end
  end

  private

  # Do some basic error checking on variables. It's fairly basic for now.
  def error_check
    raise "Subject is blank!" if @subject.strip.length == 0
    raise "Subject is long." if @subject.length > 120

    raise "Body is blank!" if @body.strip.length == 0
    #raise "Body is suspeciously short." if @body.strip.length < 80
  end
end

# Mailing is the meat and bones of this script, and basically does most everything right now

class Mailing
  attr_accessor :shared_netid_check
  # Accept the configuration variables and a possible message parsing block.
  #
  # TO-DO: Document variables expected/required/optional
  def initialize(configuration,message_parse_block=nil)
    @shared_netid_check = nil
    @configuration = configuration
    initialize_log
    @message_parse_block = message_parse_block
    load_message_file
  end

  private
  # Reads the message file and saves it as a constant for later use
  def load_message_file
    message_file = File.open(@configuration[:message_file],"r")
    # Make this a constant so we don't actually nuke it without an error
    @Message = message_file.read
  end

  def initialize_log
    if @configuration[:debug].nil?
      @logger = Yell.new format: Yell::ExtendedFormat do |l|
        l.adapter :datefile, 'send.log'
        l.adapter STDOUT
      end
    else
      @logger = Yell.new format: Yell::ExtendedFormat do |l|
        l.adapter :datefile, 'test.log'
        l.adapter STDOUT
      end
    end
  end

  def log_event(sent_to,cc=nil)
      event = "Message sent to #{sent_to}"
      event << " CC: #{cc}" if cc
      @logger.info event
  end


  # If called, will check for shared NetID administrators and return those as a list, or if format is set as anything,
  # as a pipe-seperated list.
  def check_for_shared_netid(netid,format=nil)

    uri = URI.parse("https://iam-ws.u.washington.edu:7443/group_sws/v1/group/u_netid_#{netid}_admins/member")
    cert = File.read("/etc/ssl/certs/ldapmgmt.cac.washington.edu.cert")
    key = File.read("/etc/ssl/certs/ldapmgmt.cac.washington.edu.key")
    #cert = File.read("/home/nikky/nikky_cac_washington_edu.cert")
    #key = File.read("/home/nikky/nikky_cac_washington_edu.key")

    http = Net::HTTP.new(uri.host,uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    http.cert = OpenSSL::X509::Certificate.new(cert)
    http.key = OpenSSL::PKey::RSA.new(key)
    #http.ca_file = "/home/nikky/uwca.crt"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == '404'
      #puts "It looks like this NetID isn't a shared NetID, or doesn't exist."
      #puts response.code
      return nil
    elsif response.code != '200'
      raise "The service didn't return a valid 200 response: #{response.code}"
    end

    doc = Nokogiri::HTML(response.body)
    netids = ''
    doc.css('li').each_with_index do |li,index|
      if format
        netids += "#{doc.css('li')[index].text}|"
      else
        puts doc.css('li')[index].text
      end
    end
    return netids.chomp("|") if netids != ''
  end

  # reads the users file. I make it pretty sparse, and by default the only thing it assumes is that spot 0 is the "to" field. Everything else is optional
  # and up to the implementor and their optional block to parse accordingly.
  def parse_user_file
    @data = []
    @data = CSV.read(@configuration[:file])
    puts "I successfully parsed #{@data.count} lines of data. Here's the first one: \n#{@data[0]}\n\n"
    # Return the nice data array
    @data
  end


  # This will parse a "to" "cc" or "bcc" email group for an individual message, and do the following by default:
  # * Check to see if the list has pipes, and if it does, convert it to an array
  # * Check to see if each email address has an @ in it, if not, it will add on the default domain at the end
  #
  # Additionally, if shared is defined (1), it will:
  # * Check to see if the NetID is a shared NetID, and if necessary, return the admins instead of the NetID itself.

  def parse_email_address(emails,shared=nil)
    emails = check_for_shared_netid(emails,1) if shared
    emails = emails.split("|") if emails =~ /|/
    if emails.class.to_s == "String"
      parsed_emails = emails + "@" + @configuration[:domain] if emails !~ /@/
    elsif emails.class.to_s == "Array"
      # this is ugly
      emails_string = ""
      emails.each do |address|
        address = address + "@" + @configuration[:domain] if address !~ /@/
        emails_string += "#{address}, "
      end
      emails_string.chomp(", ")
    end
  end

  public

  # Send the messages
  def send_message
    # First, let's grab the users!
    parse_user_file
    # If we're sending for reals, have an extra check to make sure
    if $debug.nil?
      puts "Warning! You're about to send a message to #{@data.count} users using the data file #{@configuration[:file]} with the subject \"#{@configuration[:subject]}\"  Are you sure? [y]"
      raise "User input: quit" unless gets.strip == 'y'
    end
    # parse through each data element (which contains at least array[0] = to
    @data.each_with_index do |local_data,index|
      # shunt it to the email parsing method
      to = parse_email_address(local_data[0])
      # shunt it to the email parsing method with the shared NetID check. It's hardcoded in for right now...

      cc = parse_email_address(local_data[0],1) if @shared_netid_check
      # get the body by using the parse_message_contents method, which provides the entire row of data to the block (see below)
      body = parse_message_contents(local_data)
      # create a new message object
      mail = Message.new(@configuration[:subject],@configuration[:from],to,body,cc)
      # tell them what was happening if we're not in debug (if in debug, send_message will spit out raw variables instead
      puts "#{index}: Sending mail to #{to} (#{Time.now})\n" unless $debug
      # send it!
      mail.send_message
      # assuming all went well, write something to the log depending on what we're doing
     # puts "\n==>I would have sent a message, but I didn't, because I'm in debug mode.<==" if @configuration[:debug]
      log_event(to,cc)
    end
   
  end
  def parse_message_contents(local_data=nil)
    return @Message unless @message_parse_block
    message = @Message.dup
    @message_parse_block.call(local_data)
  end
end
