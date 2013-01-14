require 'spec_helper'

describe ::Libfchat::WebAPI do
  before :each do
    @webapi = ::Libfchat::WebAPI.new
  end

  it "takes no parameters and returns a WebAPI object" do
    @webapi.should be_an_instance_of ::Libfchat::WebAPI
  end

  # These checks can get me locked out
  #describe "badlogins:" do
  #  it "raises an exception when it logs in without credentials" do
  #    expect {@webapi.get_ticket('','')}.to raise_error
  #  end
  #
  #  it "raises an exception when it logs in with bad credentials" do
  #    expect {@webapi.get_ticket('jippenbots','')}.to raise_error
  #  end #badlogins
  #end

end
