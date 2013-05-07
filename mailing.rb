require 'pony'
require 'yell'
require './message'
require './user_file_module'
require './message_body_module'
require './shared_netid'

Yell.new :datefile, :name => 'Mailing'

class Mailing
  attr_accessor :args
  attr_reader :messages
  include Yell::Loggable

  def initialize(args={}, &message_body)
    args[:send_method] ||= :sendmail
    args[:sleep_time] ||= 3
    args[:cc_netid_admins] ||= false
    args[:debug] ||= false

    if args[:key] && args[:cert]
      @shared_netid = SharedNetid.new({
        cert: File.read(args[:cert]),
        key: File.read(args[:key])
        })
    elsif args[:key] || args[:cert]
      raise "Key or cert provided, but not both!"
    end

    @args = args
    @messages = []
    @message_body = message_body

    # I should be my own block/method
    if debug?
      logger.debug "Initialized new debug mailer: #{self.inspect}"
    else
      logger.info "Initialized new production mailer: #{self.inspect}"
    end

  end

  def load_messages_from_csv_file
    raise "No file specified, include in Mailing init as :file" if @args[:file].nil?

    UserFile::parse(@args[:file]).each do |individual_message|
      subject = @args[:subject]
      from = @args[:from]
      to = add_domain_to_user(individual_message[:to])

      shared = @shared_netid.check_for_shared_netid(individual_message[:to])
      if shared
        cc = shared.map{|netid| netid + "@#{@args[:default_domain]}"}.join(", ")
      end

      body = MessageParse.do(individual_message, @message_body)

      message = Message.new({
        subject: subject,
        from: from,
        to: individual_message[:to],
        cc: cc,
        body: body
        })

      @messages << message

    end
  end

  def << (message)
    add_message(message)
  end

  def add_message(message)
    if verify_object_is_message(message)
      @messages << message
      logger.info "Message #{message} added to #{self}"
    else
      false
      logger.warn "Message #{message} not added to #{self}; not a message."
    end
  end

  def debug?
    @args[:debug]
  end

  def do
    raise MailingError,  "No Messages to send!" if @messages.empty?

    messages_sent = 0

    @messages.each do |message|
      mail_message(message) unless debug?
      debug_message(message) if debug?
      messages_sent += 1
      sleep @args[:sleep_time] unless debug?
    end
    messages_sent
  end

  private

  def add_domain_to_user(user)
    if user =~ /@/
      user
    else
      user + "@#{args[:default_domain]}"
    end
  end


  def verify_object_is_message(message)
    if !message.respond_to?(:subject)
      false
    elsif !message.respond_to?(:to)
      false
    elsif !message.respond_to?(:from)
      false
    elsif !message.respond_to?(:body)
      false
    else
      true
    end
  end

  def verify_message_is_complete(message)
    %w(subject body to from).each do |field|
      raise MailingError, "Empty #{field}" if message.send(field).empty?
    end
  end

  def mail_message(message)
    begin
      Pony.mail(
        to: message.to,
        from: message.from,
        subject: message.subject,
        body: message.body,
        cc: message.cc,
        bcc: message.bcc,
        via: @args[:send_method],
        headers: { "mailer" => "nikkyMail" }
        )
      logger.info "#{message} to #{message.to} sent successfully at #{Time.now}"
    rescue Exception => e
      logger.error "#{message.inspect} Failed to Send! #{e}; that's all I know."
    end

  end

  def debug_message(m)
    msg_hash = {
      to: m.to,
      from: m.from,
      subject: m.subject,
      body: m.body,
      cc: m.cc,
      bcc: m.bcc,
      via: @args[:send_method],
      headers: { "mailer" => "nikkyMail" }
    }
    logger.debug "Message not sent #{msg_hash}"

  end
end

class MailingError < RuntimeError
      # I'm a shill, and I have serious exestential questions about my very
      # existance as a class.
    end
