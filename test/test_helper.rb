# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
$:.unshift File.expand_path(".", __FILE__)

require 'test/unit'
begin
  require 'turn/autorun'
rescue LoadError
  "This will look better if you install the turn gem"
end

