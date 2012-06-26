module Libfchat
  begin
    require 'rubygems'
  rescue LoadError
    #I don't actually NEED rubygems, unless on 1.8
  end
  require 'net/http'
  require 'multi_json'
  
  class WebAPI
    attr_reader :ticket

    def get_ticket(account,password)
      uri = URI('http://www.f-list.net/json/getApiTicket.php')
      res = Net::HTTP.post_form(uri,
                                'account' => account,
                                'password' => password)

      json = MultiJson.load(res.body)
      if json['ticket']
        @ticket = json['ticket']
      end
      return json
    end

  end
end
