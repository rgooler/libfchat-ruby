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
  require 'logger'
  require 'insensitive_hash/minimal'
  require 'libfchat/version'
  require 'libfchat/webapi'
  
  class Fchat
    attr_reader :ticket
    attr_accessor :websocket

    attr_reader :version
    attr_reader :clientname
    attr_reader :me
    
    attr_reader :chat_max
    attr_reader :priv_max
    attr_reader :lfrp_max
    attr_reader :lfrp_flood
    attr_reader :msg_flood
    attr_reader :permissions

    attr_accessor :friends
    attr_accessor :ignore
    attr_accessor :ops
    attr_accessor :users
    attr_accessor :rooms
    attr_accessor :logger

    ##
    # Initialize the object with the name and version. 
    # Default to just identifying as the library

    def initialize(clientname="libfchat-ruby by Jippen Faddoul ( http://github.com/jippen/libfchat-ruby )",version=Libfchat::VERSION, level=Logger::DEBUG)
      @clientname = clientname
      @version = version
      @users = InsensitiveHash.new
      @rooms = InsensitiveHash.new
      @logger = Logger.new(STDOUT)
      @logger.level = level
    end

    ##
    # Some method_missing magic to make ruby handle just throwing around
    # commands that may or may not exist.

    def method_missing(method_name, *args, &block)
      # Try to handle all three-letter strings
      if method_name.to_s[4,7] =~ /[A-Z]{3}/
        return nil
      else
        super(method_name,*args,&block)
      end
    end

    ##
    # Parse message received from server
    def parse_message(msg)
      type = msg[0,3]
      begin
        data = MultiJson.load(msg[4..-1])
      rescue
        data = MultiJson.load('{}')
      end

      @logger.debug("<< #{msg}")

      begin
        self.send("got_#{type}",data)
      rescue
      end
    end

    ##
    # Login to fchat as a specific user, and start the event machine

    def login(server,account,password,character,timeout=30)
      webapi = Libfchat::WebAPI.new
      @ticket = webapi.get_ticket(account,password)
      @me = character

      EM.run {
        @websocket = Faye::WebSocket::Client.new(server)

        @websocket.onopen = lambda do |event|
          #When we connect, log in
          self.IDN(account, character, ticket)
        end

        @websocket.onclose = lambda do |event|
          @websocket = nil
        end

        @websocket.onmessage = lambda do |event|
          self.parse_message(event.data)
        end
      }
    end

    ##
    # Generic message sender
    def send_message(type, json)
      jsonstr = ::MultiJson.dump(json)
      msg = "#{type} #{jsonstr}"
      if type == 'IDN'
        json[:ticket] = '[REDACTED]'
      end
      filteredjsonstr = ::MultiJson.dump(json)
      @logger.debug(">> #{type} #{filteredjsonstr}")
      @websocket.send(msg)
    end

    # ====================================================== #
    #               Always respond to these                  #
    # ====================================================== #
    
    ##
    # Respond to keepalive ping messages
    def got_PIN(message)
      self.send('PIN')
    end

    ##
    # Know thyself
    def got_IDN(message)
      @me = message['character']
    end

    ##
    # Store server-side variables
    def got_VAR(message)
      if message['variable'] == 'chat_max'
        @chat_max = message['value']
      elsif message['variable'] == 'priv_max'
        @priv_max = message['value']
      elsif message['variable'] == 'lfrp_max'
        @lfrp_max = message['value']
      elsif message['variable'] == 'lfrp_flood'
        @lfrp_flood = message['value']
      elsif message['variable'] == 'msg_flood'
        @msg_flood = message['value']
      elsif message['variable'] == 'permissions'
        @permissions = message['value']
      else
        raise "ERROR: Do not know how to handle VAR #{message}"
      end
    end
    
    ##
    # Store list of ops
    def got_ADL(message)
      @ops = message['ops']
    end

    ##
    # Store list of friends
    def got_FRL(message)
      @friends = message['characters']
    end

    ##
    # Store list of ignored users
    def got_IGN(message)
      @ops = message['characters']
    end

    ##
    # Store list of online users
    def got_LIS(message)
      message['characters'].each do |character|
        @users[character[0]] = {
          'gender'  => character[1],
          'status'  => character[2],
          'message' => character[3]
        }
      end
    end

    ##
    # Handle user logging on
    def got_NLN(message)
      @users[message['identity']] = {
          'gender'  => message['gender'],
          'status'  => message['status'],
          'message' => ""
        }
    end
 
    ##
    # Handle user changing status
    def got_STA(message)
      @users[message['character']] = {
          'gender'  => @users[message['character']]['gender'],
          'status'  => message['status'],
          'message' => message['statusmsg']
        }
    end
 
    ##
    # Handle user logging off
    def got_FLN(message)
      @users.delete(message['character'])
      @rooms.each do |room|
        room['characters'].delete(message['character'])
      end
    end
 
    ##
    # Store data about newly joined chatroom
    def got_JCH(message)
      begin
        @rooms[message['channel']]['characters'].push(message['character']['identity'])
      rescue
        @rooms[message['channel']] = {
          'title'       => message['title'],
          'description' => '',
          'characters'  => [],
          'ops'         => [],
        }
      end
    end

    ##
    # Store ops list for room
    def got_COL(message)
      @rooms[message['channel']]['ops'] = message['oplist']
    end

    ##
    # Store userlist for newly joined chatroom
    def got_ICH(message)
      message['users'].each do |user|
        @rooms[message['channel']]['characters'].push(user['identity'])
      end
    end

    ##
    # Handle user leaving chatroom
    def got_LCH(message)
      @rooms[message['channel']]['characters'].delete(message['character'])
    end

    ##
    # Store description for newly joined chatroom
    def got_CDS(message)
      @rooms[message['channel']]['description'] = message['description']
    end

    ##
    ##
    # ====================================================== #
    # All commands that can be sent by a client have helpers #
    # ====================================================== #

    ##
    # Performs an account ban against a characters account. 
    #
    # *This command requires chat op or higher.*
    def ACB(character)
      json = {:character => character}
      self.send_message('ACB',json)
    end

    ##
    # Adds a character to the chat operator list.
    #
    # *This command is admin only.*
    def AOP(character)
      json = {:character => character}
      self.send_message('AOP',json)
    end

    ##
    # Requests a list of currently connected alts for a characters account.
    #
    # *This command requires chat op or higher.*
    def AWC(character)
      json = {:character => character}
      self.send_message('AWC',json)
    end

    ##
    # Broadcasts a message to all connections.
    # *This command is admin only.*
    def BRO(message)
      json = {:message => message}
      self.send_message('AWC',json)
    end

    ##
    # Request the channel banlist.
    #
    # *This command requires channel op or higher.*
    def CBL(channel)
      json = {:channel => channel}
      self.send_message('CBL',json)
    end

    ##
    # Bans a character from a channel
    #
    # *This command requires channel op or higher.*
    def CBU(channel,character)
      json = {:channel   => channel,
              :character => character}
      self.send_message('CBU',json)
    end

    ##
    # Create an Ad-hoc Channel
    def CCR(channel)
      json = {:channel => channel}
      self.send_message('CCR',json)
    end

    ##
    # This command is used by an admin or channel owner to set a new 
    # channel description.
    #
    # *This command requires channel op or higher.*
    def CDS(channel, description)
      json = {:channel => channel,
              :description => description}
      self.send_message('CDS',json)
    end

    ##
    # Request a list of all public channels
    def CHA()
      self.send_message('CHA',{})
    end

    ##
    # Sends an invitation for a channel to a user
    def CIU(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send_message('CIU',json)
    end

    ##
    # Kick a user from a channel
    #
    # *This command requires channel op or higher*
    def CKU(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send_message('CKU',json)
    end

    ##
    # Op a user in a channel
    #
    # *This command requires channel op or higher*
    def COA(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send_message('COA',json)
    end

    ##
    # Request a list of channel ops
    def COL(channel)
      json = {:channel => channel }
      self.send_message('COL',json)
    end

    ##
    # Creates a global channel
    #
    # *This command is admin only*
    def CRC(channel)
      json = {:channel => channel }
      self.send_message('CRC',json)
    end

    ##
    # Unban a user from a channel
    #
    # *This command requires channel op or higher*
    def CUB(channel,character)
      json = {:channel   => channel,
              :character => character }
      self.send_message('CUB',json)
    end

    ##
    # Request that a character be stripped of chatop status
    #
    # *This command is admin only*
    def DOP(character)
      json = { :character => character }
      self.send_message('DOP',json)
    end

    ##
    # Do a search for a kink with specific genders
    def FKS(kink,genders)
      json = { :kink    => kink,
               :genders => genders }
      self.send_message('FKS',json)
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
      self.send_message('IDN', json)
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
      self.send_message('IGN',json)
    end

    ##
    # Request that a character be IP banned
    #
    # *This command is admin only*
    def IPB(character)
      json = { :character => character }
      self.send_message('IPB',json)
    end

    ##
    # Send a channel join request
    def JCH(channel)
      json = { :channel => channel }
      self.send_message('JCH',json)
    end

    ##
    # Request a character to be kicked
    #
    # *This command requires channel op or higher*
    def KIK(character)
      json = {:character => character }
      self.send_message('KIK',json)
    end

    ##
    # Request a character's list of kinks
    def KIN(character)
      json = {:character => character }
      self.send_message('KIN',json)
    end

    ##
    # Leave a channel
    def LCH(channel)
      json = {:channel => channel }
      self.send_message('LCH',json)
    end

    ##
    # Send a message to a channel
    def MSG(channel,message)
      json = {:channel => channel,
              :message => message }
      self.send_message('MSG',json)
    end

    ##
    # List presence of ops in all rooms
    def OPP()
      self.send_message('OPP',{})
    end

    ##
    # Request a list of open private rooms
    def ORS()
      self.send_message('ORS',{})
    end

    ##
    # Respond to a ping request
    def PIN()
      self.send_message('PIN',{})
    end

    ##
    # Sends a prive message to another user
    def PRI(recipient,message)
      json = {:recipient => recipient,
              :message   => message }
      self.send_message('PRI',json)
    end

    ##
    # Do a profile request
    def PRO(character)
      json = {:character => character }
      self.send_message('PRO',json)
    end

    ##
    # Advertises the first open private channel owned by the client 
    # in the given channel
    def RAN(channel)
      json = {:channel => channel }
      self.send_message('RAN',json)
    end

    ##
    # Roll dice in a channel
    def RLL(channel,dice)
      json = {:channel => channel,
              :dice    => dice }
      self.send_message('RLL',json)
    end

    ##
    # Set a private room's status to closed or open
    #
    # *This command requires channel op or higher*
    def RST(channel,status)
      json = {:channel   => channel,
              :status    => status }
      self.send_message('RST',json)
    end

    ##
    # Reward a user, for instance, for finding a bug
    #
    # *This command is admin only*
    def RWD(character)
      json = {:character => character }
      self.send_message('RWD',json)
    end

    ##
    # Request a new status to be set for your character
    def STA(status,statusmsg)
      json = {:status    => status,
              :statusmsg => statusmsg }
      self.send_message('STA',json)
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
      self.send_message('TMO',json)
    end

    ##
    # User x is typing/stopped typing/entered text for private messages
    #
    # Available values for status: clear, paused, typing
    def TPN(character,status)
      json = {:character => character,
              :status    => status }
      self.send_message('TPN',json)
    end

    ##
    # Unban a character
    #
    # *This command requires chat op or higher*
    def UBN(character)
      json = {:character => character }
      self.send_message('UBN',json)
    end

  end #End of class
end #End of namespace
