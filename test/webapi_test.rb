# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)

require 'test_helper'
require 'libfchat/webapi'

class TestWebAPI < Test::Unit::TestCase

  def test_can_create_object
    j = Libfchat::WebAPI.new
    assert_equal true, j.is_a?(Object)
  end

  def test_no_credentials_gives_error
    j = Libfchat::WebAPI.new
    ticket = j.get_ticket('','')
    assert_equal 'Invalid username.', ticket['error']
  end

  def test_bad_password_gives_error
    j = Libfchat::WebAPI.new
    ticket = j.get_ticket('jippenbots','')
    assert_equal 'Password mismatch.', ticket['error']
  end

end
