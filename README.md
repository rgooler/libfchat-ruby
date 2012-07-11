[![Build Status](https://secure.travis-ci.org/jippen/libfchat-ruby.png?branch=master)](http://travis-ci.org/jippen/libfchat-ruby)

libfchat-ruby
=============

A library for connecting to F-chat ( http://f-list.net ), written in Ruby.

Tutorial
========
This gem is designed to make it easy to build a bot via the magic of open
objects and monkey-patching. On its own, this is just going to connect, 
discard messages, and keep the client connected to the server. To do that,
the following code is all that is required.

    require 'libfchat/fchat'
    
    bot = Libfchat::Fchat.new
    
    server = 'ws://chat.f-list.net:9722'
    user   = 'some_user_name'
    pass   = 'some_password'
    char   = 'some_character'
    
    bot.login(server,user,pass,char)


Now, how to make it do something useful? Just tell it how to handle incoming
commands. The full list is availble at http://wiki.f-list.net/index.php/FChat_server_commands

Simply add this to your source file, after the bot.login line.

    class Libfchat::Fchat
      # Respond to any Private Message with "Hello"
      def got_PRI(hashtable)
        recipient = hashtable['character']
        message   = "Hello"
        self.send('send_message','PRI',recipient,message)
      end
    end

And now, the bot can handle private messages, and behave as you expect!

The library itself has bindings for all client-sendable messages, but you (the
developer) need to add support for the messages sent from the server. All you
need to do, though, is provide a new method called got\_XXX(message), where
XXX is the three-letter code. message will be set to a hash table parsed from
the json sent by the server, so you can just use it.


FAQ
===

Q. Where can I learn Ruby?
A. Google it. I recommend Ruby Koans, along with some tutorials.

Q. Can you write a bot for me?
A. No.

Q. I found a bug...
A. Please leave me a ticket at https://github.com/jippen/libfchat-ruby/issues 
describing the bug, how to trigger it, and what you expected to happen.

Q. I added an awesome feature, do you want it?
A. Probably. Send me a pull request, and if it fits, I'll gladly put it in!

Q. When's it going to be done?
A. Silence, child, or I'll pull this thing around and we'll go back home!

