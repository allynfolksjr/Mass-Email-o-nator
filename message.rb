class Message
  attr_accessor :subject, :from, :cc, :bcc, :to, :body
  def initialize(args={})
    %w(subject from cc bcc to body).map { |i| i.to_sym }.each do |attr|
      if args[attr]
        instance_variable_set("@#{attr}",args[attr])
      else
        instance_variable_set("@#{attr}","")
      end
    end
  end

  def inspect(include_body=false)

  end

end

class InvalidMessageError < RuntimeError
end
