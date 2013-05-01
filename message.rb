class Message
  attr_accessor :subject, :from, :recipient, :cc, :bcc
end

class InvalidMessageError < RuntimeError
end
