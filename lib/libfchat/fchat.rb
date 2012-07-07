module Libfchat
  begin
    require 'rubygems'
  rescue LoadError
    #I don't actually NEED rubygems, unless on 1.8
  end
  require 'net/http'
  require 'multi_json'
  require 'eventmachine'
  require 'em-http-request'
  require 'libfchat/webapi'
  
  class Fchat
    attr_reader :ticket

    def login(server,account,password,timeout=30)
      webapi = Libfchat::WebAPI.new
      @ticket = webapi.get_ticket(account,password)

      EventMachine.run {
        http = EventMachine::HttpRequest.new(server).get :timeout => timeout
        http.errback { puts "Could not connect to " + server }
        http.callback { 
          puts "Websocket connected"
        }

        http.stream { |msg|
          puts "Received: #{msg}"
        }
      }
    end

  end
end
