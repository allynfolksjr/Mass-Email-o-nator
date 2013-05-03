require 'pony'

class Mailing
  attr_accessor :args
  def initialize(args={})
    args[:send_method] ||= :sendmail
    args[:sleep_time] ||= 3
    args[:cc_netid_admins] ||= false
    args[:debug] ||= false
    @args = args
    @messages = []
  end

  def add_message(message)
    if verify_object_is_message(message)
      @messages << message
    else
      false
    end
  end

  def messages
    @messages
  end

  def debug?
    @args[:debug]
  end

  def messages=(message_list)
    @messages = message_list
  end

  def do
      raise MailingError,  "No Messages to send!" if @messages.empty?

      messages_sent = 0

      @messages.each do |message|
        verify_message_is_complete(message)
      end

      @messages.each do |message|
        mail_message(message) unless debug?
        debug_message(message) if debug?
        messages_sent += 1
        sleep @args[:sleep_time] unless debug?
      end
      messages_sent
    end

    private

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
      raise MailingError, "Empty Subject!" if message.subject.empty?
      raise MailingError, "Empty Body!" if message.body.empty?
      raise MailingError, "Empty To!" if message.to.empty?
      raise MailingError, "Empty From!" if message.from.empty?
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
        "Message to #{message.to} sent successfully at #{Time.now}"
      rescue Exception => e
        "Message Failed to Send! #{e}; that's all I know."
      end

    end

    def debug_message(m)
      {
         to: m.to,
          from: m.from,
          subject: m.subject,
          body: m.body,
          cc: m.cc,
          bcc: m.bcc,
          via: @args[:send_method],
          headers: { "mailer" => "nikkyMail" }
        }
  end
end

  class MailingError < RuntimeError
    # I'm a shill, and I have serious exestential questions about my very
    # existance as a class.
  end
