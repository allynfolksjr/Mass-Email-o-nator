module MessageParse
  def self.do(data,raw_body)
    # yield(data)
    raw_body.call(data)
  end
end
