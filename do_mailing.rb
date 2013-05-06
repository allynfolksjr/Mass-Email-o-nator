require './message'
require './mailing'
require './user_file_module'
require './shared_netid'
require './message_body_module'

mailing = Mailing.new({
  debug:true
  })

shared_netid = SharedNetid.new({
  cert: File.read("/home/nikky/nikky_cac_washington_edu.cert"),
  key: File.read("/home/nikky/nikky_cac_washington_edu.key")
  })

subject = "Test; Hello"
from = "test@example.com"

bodyraw = lambda do |data|
  "hello #{data[:to]}, here's some stuff #{data[:data2]}"
end


UserFile::parse("spec/mocks/csv_user_file.txt").each do |message_args|
  to = message_args[:to]

  shared_netid_check = shared_netid.check_for_shared_netid(to)
  if shared_netid_check
    cc = shared_netid_check.map{|netid| netid + "@uw.edu"}.join(", ")
  end

  body = MessageParse.do(message_args, &bodyraw)


  message = Message.new({
    subject: subject,
    from: from,
    to: message_args[:to],
    cc: cc,
    body: body
    })

  mailing << message

end

mailing.do
