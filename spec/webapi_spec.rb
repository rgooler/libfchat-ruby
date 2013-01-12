require 'spec_helper'

describe ::Libfchat::WebAPI do
  before :each do
    @webapi = ::Libfchat::WebAPI.new
  end

  describe "#new" do
    it "takes no paramiters and returns a WebAPI object" do
      @webapi.should be_an_instance_of ::Libfchat::WebAPI
    end
  end

end
