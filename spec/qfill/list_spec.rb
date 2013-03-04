require 'spec_helper'
describe Qfill::List do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { Qfill::List.new() }.to raise_error(ArgumentError)
      end
    end
    context "with name" do
      before :each do
        @arguments = { :name => "High List" }
      end
      it "should not raise any errors" do
        expect { Qfill::List.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with name" do
        Qfill::List.new(@arguments).name.should == 'High List'
      end
    end
    context "with elements" do
      before :each do
        @arguments = {  :name => "High List",
                        :elements => [1,2] }
      end
      it "should instantiate with elements" do
        Qfill::List.new(@arguments).elements.should == [1,2]
      end
    end
    context "with filter" do
      before :each do
        lambda = -> (object) { !object.nil? }
        @filter = Qfill::Filter.new(lambda)
        @arguments = {  :name => "High List",
                        :elements => [1, 2],
                        :filter => @filter }
      end
      it "should instantiate with processor" do
        Qfill::List.new(@arguments).filter.should be_a(Qfill::Filter)
        Qfill::List.new(@arguments).filter.should == @filter
      end
    end
  end

end
