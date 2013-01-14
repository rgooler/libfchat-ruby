#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
$:.push File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'yaml'
require 'logger'
require 'libfchat/fchat'
require 'libfchat/version'

bot = ::Libfchat::Fchat.new("LibFchat by Jippen Faddoul ( http://github.com/jippen/libfchat-ruby )",::Libfchat::VERSION)
bot.logger.level = Logger::DEBUG

config = YAML.load_file('config/fchat.yaml')

bot.login(config['server'],config['username'],config['password'],config['character'])
