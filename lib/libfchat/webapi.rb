module Libfchat
  require 'net/http'
  require 'json'
  
  class WebAPI
    attr_reader :ticket

    def get_ticket(account,password)
      uri = URI('http://www.f-list.net/json/getApiTicket.php')
      res = Net::HTTP.post_form(uri,
                                'account' => account,
                                'password' => password)

      json = JSON.parse(res.body)
      if json['ticket']
        @ticket = json['ticket']
      end
      return json
    end

  end
end
