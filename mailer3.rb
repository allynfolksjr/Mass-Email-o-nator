require 'csv'
require 'pony'
require 'net/http'
require 'uri'
require 'nokogiri'
require 'yell'

class Message
  def initialize(config)
    @message_config = config
    if @message_config[:subject].nil?
      raise "No subject!"
    elsif @message_config[:from].nil?
      raise "No from address!"
    elsif @message_config[:to].nil?
      raise "No To address!"
    elsif @message_config[:body].nil?
      raise "No body!"
    end
    @message_config[:via] = :sendmail if @message_config[:via] == nil
    @message_config[:sleep] = 2 if @message_config[:sleep] == nil
  end

  # Invoke error checking and send message.
  def send_message
    error_check
    if @message_config[:debug]
      puts "\n\n<=> Debug Mode <=>"
      puts "Via: #{@message_config[:via]}"
      puts "From: #{@message_config[:from]}"
      puts "To: #{@message_config[:to]}"
      puts "Cc: #{@message_config[:cc]}" unless @message_config[:cc].nil?
      puts "Bcc: #{@message_config[:bcc]}" unless @message_config[:bcc].nil?
      puts "Subject: #{@message_config[:subject]}\n\n"
      puts @message_config[:body]
    else
      Pony.mail(
        to: @message_config[:to],
        from: @message_config[:from],
        subject: @message_config[:subject],
        body: @message_config[:body],
        cc: @message_config[:cc],
        bcc: @message_config[:bcc],
        via: @message_config[:via],
        headers: { "mailer" => "nikkyMail" }
      )
      sleep @message_config[:sleep]
    end
  end

  private

  # Do some basic error checking on variables. It's fairly basic for now.
  def error_check
    raise "Subject is blank!" if @message_config[:subject].strip.length == 0
    raise "Subject is long!" if @message_config[:subject].length > 120
    raise "Body is blank!" if @message_config[:body].strip.length == 0
  end
end

# Mailing is the meat and bones of this script, and basically does most everything right now

class Mailing
  # Accept the configuration variables and a possible message parsing block.
  def initialize(configuration)
    @configuration = configuration
    @configuration[:message] ||= "message"
    @configuration[:message_file] ||= "message"
    @configuration[:user_file] ||= "users"
    initialize_log
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
    cert = File.read(@configuration[:cert])
    key = File.read(@configuration[:key])
    http = Net::HTTP.new(uri.host,uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    http.cert = OpenSSL::X509::Certificate.new(cert)
    http.key = OpenSSL::PKey::RSA.new(key)
    #http.ca_file = "/home/nikky/uwca.crt"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == '404'
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
    @data = CSV.read(@configuration[:user_file])
    puts "I successfully parsed #{@data.count} lines of data. Here's the first one: \n#{@data[0]}\n\n"
    @data
  end


  # This will parse a "to" "cc" or "bcc" email group for an individual message, and do the following by default:
  # * Check to see if the list has pipes, and if it does, convert it to an array
  # * Check to see if each email address has an @ in it, if not, it will add on the default domain at the end

  def parse_email_address(emails)
    emails = check_for_shared_netid(emails,1) if @configuration[:shared]
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
    if @configuration[:debug].nil?
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
      mail = Message.new ({
                            subject: @configuration[:subject],
                            from: @configuration[:from],
                            to: to,
                            body: body,
                            cc: cc,
                            debug: @configuration[:debug],
                            via: @configuration[:via],
                            sleep: @configuration[:sleep]
      })

      # tell them what was happening if we're not in debug (if in debug, send_message will spit out raw variables instead
      puts "#{index}: Sending mail to #{to} (#{Time.now})\n" unless @configuration[:debug]
      # send it!
      mail.send_message
      # assuming all went well, write something to the log depending on what we're doing
      # puts "\n==>I would have sent a message, but I didn't, because I'm in debug mode.<==" if @configuration[:debug]
      log_event(to,cc)
    end

  end
  def parse_message_contents(local_data=nil)
    return @Message unless @configuration[:message_parse_block]
    message = @Message.dup
    @configuration[:message_parse_block].call(local_data,@Message)
  end
end
