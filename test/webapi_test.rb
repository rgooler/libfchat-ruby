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
    assert_raise(RuntimeError) do
      j.get_ticket('','')
    end
  end

  def test_bad_password_gives_error
    j = Libfchat::WebAPI.new
    assert_raise(RuntimeError) do
      j.get_ticket('jippenbots','')
    end
  end

end
