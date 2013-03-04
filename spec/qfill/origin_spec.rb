require 'spec_helper'
describe Qfill::Origin do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
       expect { Qfill::Origin.new() }.to raise_error(ArgumentError)
      end
    end
    context "with name" do
      before :each do
        @arguments = { :name => "High List" }
      end
      it "should not raise any errors" do
        expect { Qfill::Origin.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with name" do
        Qfill::Origin.new(@arguments).name.should == 'High List'
      end
    end
    context "with elements" do
      before :each do
        @arguments = {  :name => "High List",
                        :elements => [1,2] }
      end
      it "should instantiate with elements" do
        Qfill::Origin.new(@arguments).elements.should == [1,2]
      end
    end
    context "with backfill" do
      before :each do
        @arguments = {  :name => "High List",
                        :elements => [1, 2],
                        :backfill => "Medium List" }
      end
      it "should instantiate with elements" do
        Qfill::Origin.new(@arguments).backfill.should == 'Medium List'
      end
    end
    context "with filter" do
      before :each do
        lambda = -> (object) { !object.nil? }
        @filter = Qfill::Filter.new(lambda)
        @arguments = {  :name => "High List",
                        :elements => [1, 2],
                        :backfill => "Medium List",
                        :filter => @filter }
      end
      it "should instantiate with processor" do
        Qfill::Origin.new(@arguments).filter.should be_a(Qfill::Filter)
        Qfill::Origin.new(@arguments).filter.should == @filter
      end
    end
  end

end
