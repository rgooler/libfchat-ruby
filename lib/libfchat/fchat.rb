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
      # Try to handle all three-letter strings
      if method_name.to_s[4,7] =~ /[A-Z]{3}/
        #puts "Dunno how to handle #{method_name.to_s}"
      else
        super(method_name,*args,&block)
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
          #When we connect, log in
          self.send('IDN',account,character,ticket)
        end

        @websocket.onclose = lambda do |event|
          @websocket = nil
        end

        @websocket.onmessage = lambda do |event|
          type = event.data[0,3]
          begin
            data = MultiJson.load(event.data[4..-1])
          rescue
            data = MultiJson.load('{}')
          end
          puts "<< [#{type}] #{data}"
          begin
            self.send("got_#{type}",data)
          rescue
          end
        end
      }
    end

    ##
    # Generic message sender
    def send_message(type,json)
      jsonstr = ::MultiJson.dump(json)
      msg = "#{type} #{jsonstr}"
      puts ">> #{msg}"
      @websocket.send(msg)
    end

    # ====================================================== #
    #               Always respond to pings                  #
    # ====================================================== #
    
    ##
    # Respond to keepalive ping messages
    def got_PIN(message)
      self.send('PIN')
    end

    # ====================================================== #
    # All commands that can be sent by a client have helpers #
    # ====================================================== #

    ##
    # Performs an account ban against a characters account. 
    #
    # *This command requires chat op or higher.*
    def ACB(character)
      json = {:character => character}
      self.send('send_message','ACB',json)
    end

    ##
    # Adds a character to the chat operator list.
    #
    # *This command is admin only.*
    def AOP(character)
      json = {:character => character}
      self.send('send_message','AOP',json)
    end

    ##
    # Requests a list of currently connected alts for a characters account.
    #
    # *This command requires chat op or higher.*
    def AWC(character)
      json = {:character => character}
      self.send('send_message','AWC',json)
    end

    ##
    # Broadcasts a message to all connections.
    # *This command is admin only.*
    def BRO(message)
      json = {:message => message}
      self.send('send_message','AWC',json)
    end

    ##
    # Request the channel banlist.
    #
    # *This command requires channel op or higher.*
    def CBL(channel)
      json = {:channel => channel}
      self.send('send_message','CBL',json)
    end

    ##
    # Bans a character from a channel
    #
    # *This command requires channel op or higher.*
    def CBU(channel,character)
      json = {:channel   => channel,
              :character => character}
      self.send('send_message','CBU',json)
    end

    ##
    # Create an Ad-hoc Channel
    def CCR(channel)
      json = {:channel => channel}
      self.send('send_message','CCR',json)
    end

    ##
    # This command is used by an admin or channel owner to set a new 
    # channel description.
    #
    # *This command requires channel op or higher.*
    def CCR(channel)
      json = {:channel => channel}
      self.send('send_message','CCR',json)
    end

    ##
    # Request a list of all public channels
    def CHA()
      self.send('send_message','CHA',{})
    end

    ##
    # Sends an invitation for a channel to a user
    def CIU(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send('send_message','CIU',json)
    end

    ##
    # Kick a user from a channel
    #
    # *This command requires channel op or higher*
    def CKU(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send('send_message','CKU',json)
    end

    ##
    # Op a user in a channel
    #
    # *This command requires channel op or higher*
    def COA(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send('send_message','COA',json)
    end

    ##
    # Request a list of channel ops
    def COA(channel)
      json = {:channel => channel }
      self.send('send_message','CKU',json)
    end

    ##
    # Creates a global channel
    #
    # *This command is admin only*
    def CRC(channel)
      json = {:channel => channel }
      self.send('send_message','CRC',json)
    end

    ##
    # Unban a user from a channel
    #
    # *This command requires channel op or higher*
    def CUB(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send('send_message','CUB',json)
    end

    ##
    # Request that a character be stripped of chatop status
    #
    # *This command is admin only*
    def DOP(character)
      json = { :character => character }
      self.send('send_message','DOP',json)
    end

    ##
    # Do a search for a kink with specific genders
    def FKS(kink,genders)
      json = { :kink    => kink,
               :genders => genders }
      self.send('send_message','FKS',json)
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

    ##
    # Deal with ignoring characters.
    #
    # Available 'actions'
    #  notify: send this when someone on the ignore list sends a message to you
    #  add: Add a character to your ignore list
    #  remove: Remove a character from your ignore list
    def IGN(action,character)
      json = { :action    => action,
               :character => character }
      self.send('send_message','IGN',json)
    end

    ##
    # Request that a character be IP banned
    #
    # *This command is admin only*
    def IPB(character)
      json = { :character => character }
      self.send('send_message','IPB',json)
    end

    ##
    # Send a channel join request
    def JCH(channel)
      json = { :channel => channel }
      self.send('send_message','JCH',json)
    end

    ##
    # Request a character to be kicked
    #
    # *This command requires channel op or higher*
    def KIK(character)
      json = {:character => character }
      self.send('send_message','KIK',json)
    end

    ##
    # Request a character's list of kinks
    def KIN(character)
      json = {:character => character }
      self.send('send_message','KIN',json)
    end

    ##
    # Leave a channel
    def LCH(channel)
      json = {:channel => channel }
      self.send('send_message','LCH',json)
    end

    ##
    # Send a message to a channel
    def MSG(channel,message)
      json = {:channel => channel,
              :message => message }
      self.send('send_message','MSG',json)
    end

    ##
    # List presence of ops in all rooms
    def OPP()
      self.send('send_message','OPP',{})
    end

    ##
    # Request a list of open private rooms
    def ORS()
      self.send('send_message','ORS',{})
    end

    ##
    # Respond to a ping request
    def PIN()
      self.send('send_message','PIN',{})
    end

    ##
    # Sends a prive message to another user
    def PRI(recipient,message)
      json = {:recipient => recipient,
              :message   => message }
      self.send('send_message','PRI',json)
    end

    ##
    # Do a profile request
    def PRO(character)
      json = {:character => character }
      self.send('send_message','PRO',json)
    end

    ##
    # Advertises the first open private channel owned by the client 
    # in the given channel
    def RAN(channel)
      json = {:channel => channel }
      self.send('send_message','RAN',json)
    end

    ##
    # Roll dice in a channel
    def RLL(channel,dice)
      json = {:channel => channel,
              :dice    => dice }
      self.send('send_message','RLL',json)
    end

    ##
    # Set a private room's status to closed or open
    #
    # *This command requires channel op or higher*
    def RST(channel,status)
      json = {:channel   => channel,
              :status    => status }
      self.send('send_message','RST',json)
    end

    ##
    # Reward a user, for instance, for finding a bug
    #
    # *This command is admin only*
    def RWD(character)
      json = {:character => character }
      self.send('send_message','RWD',json)
    end

    ##
    # Request a new status to be set for your character
    def STA(status,statusmsg)
      json = {:status    => status,
              :statusmsg => statusmsg }
      self.send('send_message','STA',json)
    end

    ##
    # Admin or chatop command to request a timeout for a user
    # time must be a minimum of one minute, and maximum of 90 minutes
    #
    # *This command requires channel op or higher*
    def TMO(character,time,reason)
      json = {:character => character,
              :time      => time,
              :reason    => reason }
      self.send('send_message','TMO',json)
    end

    ##
    # User x is typing/stopped typing/entered text for private messages
    #
    # Available values for status: clear, paused, typing
    def TPN(character,status)
      json = {:character => character,
              :status    => status }
      self.send('send_message','TPN',json)
    end

    ##
    # Unban a character
    #
    # *This command requires chat op or higher*
    def UBN(character)
      json = {:character => character }
      self.send('send_message','UBN',json)
    end

  end #End of class
end #End of namespace
