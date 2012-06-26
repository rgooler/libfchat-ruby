# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'libfchat/version'

Gem::Specification.new do |s|
  s.name            = 'libfchat'
  s.version         = Libfchat::VERSION
  s.date            = '2012-06-25'
  s.platform        = Gem::Platform::RUBY
  s.summary         = "A library for connection to F-chat"
  s.description     = "A library for connecting to F-chat ( http://f-list.net )"
  s.authors         = ["Ryan Gooler"]
  s.email           = 'cheetahmorph@gmail.com'
  s.files           = Dir.glob('lib/libfchat/*.rb')
  s.test_files      = Dir.glob('test/*_test.rb')
  s.homepage        = 'http://github.com/jippen/libfchat'
  s.license         = 'MIT'
  s.require_path    = 'lib'

  s.add_development_dependency 'turn', '~> 0.9.5'
  s.add_development_dependency 'miniunit', '~> 1.2.1'

  s.add_runtime_dependency 'multi_json', '~> 1.3.6'
end
