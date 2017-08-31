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

    def post(endpoint, params)
      uri = URI("#{@baseurl}#{endpoint}")
      if @ticket
        params['ticket'] = @ticket
      end
      res = Net::HTTP.post_form(uri, params)
      json = MultiJson.load(res.body)
      if json['error'] != ""
        raise json['error']
      end
      return json
    end

    def get(endpoint)
      uri = URI(@baseurl)
      res = Net::HTTP.get(uri)
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

    # Bookmarks
    def bookmark_add(name)
      return self.post("/json/api/bookmark-add.php",
                      'name' => name)
    end

    def bookmark_list()
      return self.get("/json/api/bookmark-list.php")
    end

    def bookmark_remove(name)
      return self.post("/json/api/bookmark-remove.php",
                      'name' => name)
    end

    # Character data
    def character_data(name)
      return self.post("/json/api/character-data.php",
                      'name' => name)
    end

    def character_list()
      return self.get("/json/api/character-list.php")
    end

    # Misc data
    def group_list()
      return self.get("/json/api/group-list.php")
    end

    def ignore_list()
      return self.get("/json/api/ignore-list.php")
    end

    def info_list()
      return self.get("/json/api/info-list.php")
    end

    def kink_list()
      return self.get("/json/api/kink-list.php")
    end

    def mapping_list()
      return self.get("/json/api/mapping-list.php")
    end

    # Handling friend requests, friend list data
    def friend_list()
      return self.get("/json/api/friend-list.php")
    end

    def friend_remove(source_name, dest_name)
      return self.post("/json/api/friend-remove.php",
                      "source_name" => source_name,
                      "dest_name" => dest_name)
    end

    def request_accept(request_id)
      return self.post("/json/api/request-accept.php",
                      "request_id" => request_id)
    end

    def request_cancel(request_id)
      return self.post("/json/api/request-cancel.php",
                      "request_id" => request_id)
    end

    def request_deny(request_id)
      return self.post("/json/api/request-deny.php",
                      "request_id" => request_id)
    end

    def request_list()
      return self.get("/json/api/request-list.php")
    end

    def request_pending()
      return self.get("/json/api/request-pending.php")
    end

    def request_send()
      return self.get("/json/api/request-send.php")
    end

  end
end
