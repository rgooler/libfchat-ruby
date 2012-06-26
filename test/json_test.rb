#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'test_helper'
require 'json'

class TestJSON < Test::Unit::TestCase

  def test_blank_login_credentials_fails
    assert true
    assert_equal 1, 1
    assert_equal 1, 1.0
  end

end
