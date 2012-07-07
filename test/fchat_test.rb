# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)

require 'test_helper'
require 'libfchat/fchat'

class TestFchat < Test::Unit::TestCase

  def test_can_create_object
    j = Libfchat::Fchat.new
    assert_equal true, j.is_a?(Object)
  end

end
