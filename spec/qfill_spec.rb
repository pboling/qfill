require 'spec_helper'
describe Qfill do
  it "should have string version" do
    Qfill::VERSION.should be_a(String)
  end

  it "should have major, minor & patch version levels" do
    Qfill::VERSION.should =~ /\d+\.\d+\.\d+/
  end

end
