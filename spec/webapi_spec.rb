require 'spec_helper'

describe ::Libfchat::WebAPI do
  before :each do
    @webapi = ::Libfchat::WebAPI.new
  end

  it "takes no parameters and returns a WebAPI object" do
    expect(@webapi).to be_an_instance_of ::Libfchat::WebAPI
  end

end
