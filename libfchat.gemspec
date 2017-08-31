# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'libfchat/version'

Gem::Specification.new do |s|
  s.name            = 'libfchat'
  s.version         = Libfchat::VERSION
  s.date            = '2017-07-31'
  s.summary         = "A library for connection to F-chat"
  s.description     = "A library for connecting to F-chat ( http://f-list.net )"
  s.authors         = ["Ryan Gooler"]
  s.email           = 'cheetahmorph@gmail.com'
  s.files           = Dir.glob('lib/libfchat/*.rb')
  s.test_files      = Dir.glob('test/*_test.rb')
  s.homepage        = 'http://github.com/jippen/libfchat-ruby'
  s.license         = 'MIT'
  s.require_path    = 'lib'

  s.add_development_dependency('turn')
  s.add_development_dependency('miniunit')
  s.add_runtime_dependency('multi_json')
  s.add_runtime_dependency('faye-websocket')
end
