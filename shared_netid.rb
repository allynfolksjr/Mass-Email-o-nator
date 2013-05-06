require 'nokogiri'
require 'net/http'
require 'uri'
require 'netid-tools'

class SharedNetid
   def initialize(args={})
    raise "No certificate specified!" unless args[:cert]
    raise "No key specified!" unless args[:key]
    @args = args
  end

  def check_for_shared_netid(netid)
    validate_netid(netid)
    response = make_groups_shared_netid_check(netid)
    if response
      response
    else
      false
    end
  end

  private

  def make_groups_shared_netid_check(netid)
    uri = URI.parse("https://iam-ws.u.washington.edu:7443/group_sws/v1/group/u_netid_#{netid}_admins/member")
    cert = @args[:cert]
    key = @args[:key]
    http = Net::HTTP.new(uri.host,uri.port)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    http.cert = OpenSSL::X509::Certificate.new(cert)
    http.key = OpenSSL::PKey::RSA.new(key)
    http.ca_file = "/home/nikky/uwca.crt"
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    if response.code == '404'
      return nil
    elsif response.code != '200'
      raise "The service didn't return a valid 200 response: #{response.code}"
    end

    doc = Nokogiri::HTML(response.body)
    netids = []
    doc.css('li').each_with_index do |li,index|
        netids << "#{doc.css('li')[index].text}"
    end
    netids
  end

  def validate_netid(netid)
    raise "Not a valid NetID" unless Netid.validate_netid?(netid)
  end

end
