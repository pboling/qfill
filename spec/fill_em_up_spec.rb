require 'spec_helper'
describe FillEmUp do
  it "should have string version" do
    FillEmUp::VERSION.should be_a(String)
  end

  it "should have major, minor & patch version levels" do
    FillEmUp::VERSION.should =~ /\d+\.\d+\.\d+/
  end

end
