# This file contains an object designed for writing bots/clients for fchat

module Libfchat
  begin
    require 'rubygems'
  rescue LoadError
    #I don't actually NEED rubygems, unless on 1.8
  end
  require 'multi_json'
  require 'faye/websocket'
  require 'eventmachine'
  require 'libfchat/version'
  require 'libfchat/webapi'
  
  class Fchat
    attr_reader :ticket
    attr_accessor :websocket

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
    # Some method_missing magic to make ruby handle just throwing around
    # commands that may or may not exist.

    def method_missing(method_name, *args, &block)
      puts "Method_missing: #{method_name}"
      # Try to handle all three-letter strings
      puts "Trying to parse |#{method_name.to_s[0,3]}|"
      if method_name.to_s[0,3] == method_name.to_s
        puts "Dunno how to handle #{method_name.to_s}"
      else
        #super(method_name,*args,&block)
      end
    end

    ##
    # Login to fchat as a specific user, and start the event machine

    def login(server,account,password,character,timeout=30)
      webapi = Libfchat::WebAPI.new
      @ticket = webapi.get_ticket(account,password)

      EM.run {
        @websocket = Faye::WebSocket::Client.new(server)

        @websocket.onopen = lambda do |event|
          puts "Websocket connected"
          self.send('IDN',account,character,ticket)
          puts "Authentication sent"
        end

        @websocket.onclose = lambda do |event|
          @websocket = nil
        end

        @websocket.onmessage = lambda do |event|
          puts "<< #{event.data}"
        end
      }
    end

    def send_message(type,json)
      jsonstr = ::MultiJson.dump(json)
      msg = "#{type} #{jsonstr}"
      puts ">> #{msg}"
      @websocket.send(msg)
    end

    # ====================================================== #
    # All commands that can be sent by a client have helpers #
    # ====================================================== #

    ##
    # Performs an account ban against a characters account. 
    # *This command requires chat op or higher.*
    
    def ACB(character)
      json = { :character => character }
      self.send('send_message','ACB',json)
    end

    ##
    # Adds a character to the chat operator list.
    # *This command is admin only.*
      
    def AOP(character)
      json = { :character => character }
      self.send('send_message','AOP',json)
    end

    ##
    # This command is used to identify with the server.
    # NOTE: If you send any commands before identifying, you will be
    # disconnected.

    def IDN(account,
            character,
            ticket,
            cname=@clientname,
            cversion=@version,
            method="ticket")
      # Initial identification with the server
      json = {:account   => account,
              :character => character,
              :ticket    => ticket['ticket'],
              :cname     => cname,
              :cversion  => cversion,
              :method    => 'ticket'}
      self.send('send_message','IDN',json)
    end


  end
end
