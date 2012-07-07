# This file contains an object designed for writing bots/clients for fchat

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

    ##
    # Initialize the object with the name and version. 
    # Default to just identifying as the library

    def initialize(clientname="libfchat-ruby by Jippen Faddoul ( http://github.com/jippen/libfchat-ruby )",version=Libfchat::VERSION)
      @clientname = clientname
      @version = version
    end

    ##
    # Login to fchat as a specific user, and start the event machine

    def login(server,account,password,character,timeout=30)
      webapi = Libfchat::WebAPI.new
      @ticket = webapi.get_ticket(account,password)

      EventMachine.run {
        self.http = EventMachine::HttpRequest.new(server).get :timeout => timeout
        self.http.errback { puts "Could not connect to " + server }
        self.http.callback { 
          puts "Websocket connected"
          self.send_IDN(account,character,ticket)
        }

        self.http.stream { |msg|
          puts "#{msg[0,3]}: #{msg[4,-1]}"
          self.send(msg[0,3].upcase,MultiJson.load(msg[4,-1]))
        }
      }
    end

    ##
    # Some method_missing magic to make ruby handle just throwing around
    # commands that may or may not exist.

    def method_missing(method_name, *args, &block)
      # Try to handle all three-letter strings
      if method_name.to_s[0,3] == method_name.to_s
        puts "Dunno how to handle #{method_name.to_s}"
      else
        super(method_name,*args,&block)
      end
    end
  
    # ====================================================== #
    # All commands that can be sent by a client have helpers #
    # ====================================================== #

    ##
    # Performs an account ban against a characters account. 
    # *This command requires chat op or higher.*
    
    def send_ACB(character)
      json = { :character => character }
      self.http.send( "ACB " + MultiJSON.dump(json) )
    end

    ##
    # Adds a character to the chat operator list.
    # *This command is admin only.*
      
    def send_AOP(character)
      json = { :character => character }
      self.http.send( "AOP " + MultiJSON.dump(json) )
    end

    ##
    # This command is used to identify with the server.
    # NOTE: If you send any commands before identifying, you will be disconnected.

    def send_IDN(account,character,ticket,cname=@clientname,cversion=@version,method="ticket")
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
