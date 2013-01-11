# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)

require 'test_helper'
require 'libfchat/fchat'

class TestFchat < Test::Unit::TestCase

  # Test that the object is valid
  def test_can_create_object
    j = Libfchat::Fchat.new
    assert_equal true, j.is_a?(Object)
  end

  #Test that we can receive chat_max variable from server and store it correctly
  def test_can_add_server_var_chat_max
    bot = Libfchat::Fchat.new("testbot by Jippen Faddoul","1.0")
    bot.spam = false
    data = 'VAR {"variable":"chat_max","value":4096}'
    bot.parse_message(data)
    assert_equal(4096, bot.chat_max)
  end

end
