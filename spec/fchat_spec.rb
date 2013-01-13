require 'spec_helper'

describe ::Libfchat::Fchat do
  before :each do
    @bot_desc = 'Libfchat testbot by Jippen Faddoul (https://github.com/jippen/libfchat-ruby)'
    @bot_version = '1.0'
    @fchat = ::Libfchat::Fchat.new(@bot_desc, @bot_version)
    @fchat.logger.level = Logger::FATAL
  end

  it "takes no parameters and returns a Fchat object" do
    @fchat.should be_an_instance_of ::Libfchat::Fchat
  end

  describe "get_ADL" do
    it "parses correctly" do
      data = 'ADL {"ops":["Hiro","Aniko","King Mercy","Hexxy","Glitter","Feath","Becca Greene","Chromatic","Lothar","Sea","Lambeth","Susannah","R B Nicci","Lurue","Neige","Natsudra","Robert Grayson","Melly Mildri","Bastogne","Rebbi"]}'
      @fchat.parse_message(data)
      @fchat.ops.include?("Lothar").should be_true
    end

    it "should find people case-insensitively" do
      data = 'ADL {"ops":["Hiro","Aniko","King Mercy","Hexxy","Glitter","Feath","Becca Greene","Chromatic","Lothar","Sea","Lambeth","Susannah","R B Nicci","Lurue","Neige","Natsudra","Robert Grayson","Melly Mildri","Bastogne","Rebbi"]}'
      @fchat.parse_message(data)
      @fchat.ops.any?{ |s| s.casecmp("lothar")==0}.should be_true
      @fchat.ops.any?{ |s| s.casecmp("LOTHAR")==0}.should be_true
    end



  end

  describe "get_AOP" do
  end

  describe "get_BRO" do
  end

  describe "get_CDS" do
  end

  describe "get_CHA" do
  end

  describe "get_COL" do
  end

  describe "get_CON" do
  end

  describe "get_DOP" do
  end

  describe "get_ERR" do
  end

  describe "get_FLN" do
  end

  describe "get_HLO" do
  end

  describe "get_ICH" do
  end 

  describe "get_IDN" do
    it "knows its own identity" do
      data = 'IDN {"character":"Bottlebot"}'
      @fchat.parse_message(data)
      @fchat.me.should == 'Bottlebot'
    end
  end

  describe "get_JCH" do
  end

  describe "get_KID" do
  end 

  describe "get_LCH" do
  end

  describe "get_LIS" do
  end

  describe "get_NLN" do
    it "can tell that a user logged in" do
      data = 'NLN {"identity":"testguy","gender":"male","status":"online"}'
      @fchat.parse_message(data)     
      @fchat.users.should include('testguy')
    end
    
    it "can identify a user's status" do
      data = 'NLN {"identity":"testguy","gender":"male","status":"online"}'
      @fchat.parse_message(data)     
      @fchat.users['testguy']['status'].should == "online"
    end
  end

  describe "get_IGN" do
  end

  describe "get_FRL" do
  end

  describe "get_ORS" do
  end

  describe "get_PIN" do
  end

  describe "get_PRD" do
  end

  describe "get_PRI" do
  end

  describe "get_MSG" do
  end

  describe "get_LRP" do
  end

  describe "get_RTB" do
  end

  describe "get_STA" do
  end

  describe "get_SYS" do
  end 

  describe "get_TPN" do
  end

  describe "get_VAR" do
    it "correctly stores chat_max variable received from server" do
      data = 'VAR {"value":4096,"variable":"chat_max"}'
      @fchat.parse_message(data)
      @fchat.chat_max.should == 4096
    end

    it "correctly stores priv_max variable received from server" do
      data = 'VAR {"value":50000,"variable":"priv_max"}'
      @fchat.parse_message(data)
      @fchat.priv_max.should == 50000
    end

    it "correctly stores lfrp_max variable received from server" do
      data = 'VAR {"value":50000,"variable":"lfrp_max"}'
      @fchat.parse_message(data)
      @fchat.lfrp_max.should == 50000
    end

    it "correctly stores lfrp_flood variable received from server" do
      data = 'VAR {"value":600,"variable":"lfrp_flood"}'
      @fchat.parse_message(data)
      @fchat.lfrp_flood.should == 600
    end

    it "correctly stores msg_flood variable received from server" do
      data = 'VAR {"value":0.5,"variable":"msg_flood"}'
      @fchat.parse_message(data)
      @fchat.msg_flood.should == 0.5
    end

    it "correctly stores permissions variable received from server" do
      data = 'VAR {"value":0,"variable":"permissions"}'
      @fchat.parse_message(data)
      @fchat.permissions.should == 0
    end

  end

end
