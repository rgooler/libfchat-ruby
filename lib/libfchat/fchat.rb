module Libfchat
  begin
    require 'rubygems'
  rescue LoadError
    #I don't actually NEED rubygems, unless on 1.8
  end
  require 'multi_json'
  require 'eventmachine'
  require 'em-http-request'
  require 'libfchat/version'
  require 'libfchat/webapi'
  
  class Fchat
    attr_reader :ticket
    attr_accessor :http

    attr_reader :version
    attr_reader :clientname

    def initialize(clientname="libfchat-ruby by Jippen Faddoul ( http://github.com/jippen/libfchat-ruby )",version=Libfchat::VERSION)
      @clientname = clientname
      @version = version
    end

    def login(server,account,password,character,timeout=30)
      webapi = Libfchat::WebAPI.new
      @ticket = webapi.get_ticket(account,password)

      EventMachine.run {
        self.http = EventMachine::HttpRequest.new(server).get :timeout => timeout
        self.http.errback { puts "Could not connect to " + server }
        self.http.callback { 
          puts "Websocket connected"
          self.IDN()
        }

        self.http.stream { |msg|
          puts "Received: #{msg}"
        }
      }
    end

    def IDN(account,character,ticket,cname=@clientname,cversion=@version,method="ticket")
      # Initial identification with the server
      json = {:account   => account,
              :character => character,
              :ticket    => ticket,
              :cname     => cname,
              :cversion  => cversion,
              :method    => ticket}
      self.http.send( "IDN " + MultiJson.dump(json) )
    end


  end
end
