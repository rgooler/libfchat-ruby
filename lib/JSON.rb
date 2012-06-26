#!/usr/bin/env ruby
require 'net/http'

class json
  def get_token(user,pass)
    uri = URI('http://www.f-list.net/json/getApiTicket.php')
    res = Net::HTTP.post_form(uri,
                              'username' => user,
                              'password' => pass)

    body = res.body
    return body
  end
end
