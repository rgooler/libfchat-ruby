module Libfchat
  begin
    require 'rubygems'
  rescue LoadError
    #I don't actually NEED rubygems, unless on 1.8
  end
  require 'net/https'
  require 'multi_json'

  class WebAPI
    attr_reader :ticket
    attr_reader :baseurl

    def initialize(baseurl="https://www.f-list.net")
      @baseurl = baseurl
    end

    def post(path, params)
      uri = URI(:baseurl + path)
      res = Net::HTTP.post_form(uri, params)
      json = MultiJson.load(res.body)
      if json['error'] != ""
        raise json['error']
      end
      return json
    end

    def get_ticket(account, password)
      # Deprecated
      return self.getApiTicket(account, password)
    end

    def getApiTicket(account, password)
      json = self.post("/json/getApiTicket.php",
                      'account' => account,
                      'password' => password)

      if json['ticket']
        @ticket = json['ticket']
        return json
      end
    end

    def bookmark_add(name)
      uri = URI('https://www.f-list.net/json/getApiTicket.php')
      res = Net::HTTP.post_form(uri,
                                'account' => account,
                                'password' => password)

      json = MultiJson.load(res.body)
      if json['ticket']
        @ticket = json['ticket']
      else
        raise json['error']
      end
      return json
    end

  end
end
