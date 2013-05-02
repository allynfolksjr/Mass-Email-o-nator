require 'pony'

class Mailing
  attr_accessor :args
  def initialize(args={})
    args[:send_method] ||= :sendmail
    args[:sleep_time] ||= 3
    args[:cc_netid_admins] ||= false
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

  def messages=(message_list)
    @messages = message_list
  end

  def do
    raise MailingError,  "No Messages to send!" if @messages.empty?

    @messages.each do |m|
      verify_message_is_complete(m)
    end

    @messages.each do |m|
      mail_message(m)
      sleep @args[:sleep_time]
    end

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

  def mail_message(m)
   Pony.mail(
    to: m.to,
    from: m.from,
    subject: m.subject,
    body: m.body,
    cc: m.cc,
    bcc: m.bcc,
    via: @args[:send_method],
    headers: { "mailer" => "nikkyMail" }
    )
 end


end

class MailingError < RuntimeError
end

