require './mailing'

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

mailing.do
