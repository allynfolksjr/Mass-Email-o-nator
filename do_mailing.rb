require './message'
require './mailing'
require './user_file_module'
require './shared_netid'

body = lambda do |data|
   "hello #{data[:to]}, here's some stuff #{data[:data2]}"
 end



mailing = Mailing.new({
  debug:true,
  subject: "Test; hello",
  from: "test@example.com",
  default_domain: "uw.edu",
  cert: "/home/nikky/nikky_cac_washington_edu.cert",
  key: "/home/nikky/nikky_cac_washington_edu.key",
  file: "/home/nikky/Repositories/github/Mass-Email-o-nator/spec/mocks/csv_user_file.txt"
  }) {|data| "hello #{data[:to]}, here's some stuff #{data[:data2]}" }

mailing.load_messages_from_csv_file
# UserFile::parse("spec/mocks/csv_user_file.txt").each do |message_args|
#   to = message_args[:to]

#   shared_netid_check = shared_netid.check_for_shared_netid(to)
#   if shared_netid_check
#     cc = shared_netid_check.map{|netid| netid + "@uw.edu"}.join(", ")
#   end

#   body = MessageParse.do(message_args, &bodyraw)


#   message = Message.new({
#     subject: subject,
#     from: from,
#     to: message_args[:to],
#     cc: cc,
#     body: body
#     })

#   mailing << message

# end

mailing.do
