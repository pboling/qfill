require 'spec_helper'
describe FillEmUp::Origin do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
       expect { FillEmUp::Origin.new() }.to raise_error(ArgumentError)
      end
    end
    context "with name" do
      before :each do
        @arguments = { :name => "High Queue" }
      end
      it "should not raise any errors" do
        expect { FillEmUp::Origin.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with name" do
        FillEmUp::Origin.new(@arguments).name.should == 'High Queue'
      end
    end
    context "with elements" do
      before :each do
        @arguments = {  :name => "High Queue",
                        :elements => [1,2] }
      end
      it "should instantiate with elements" do
        FillEmUp::Origin.new(@arguments).elements.should == [1,2]
      end
    end
    context "with backfill" do
      before :each do
        @arguments = {  :name => "High Queue",
                        :elements => [1, 2],
                        :backfill => "Medium Queue" }
      end
      it "should instantiate with elements" do
        FillEmUp::Origin.new(@arguments).backfill.should == 'Medium Queue'
      end
    end
    context "with filter" do
      before :each do
        lambda = -> (object) { !object.nil? }
        @filter = FillEmUp::Filter.new(lambda)
        @arguments = {  :name => "High Queue",
                        :elements => [1, 2],
                        :backfill => "Medium Queue",
                        :filter => @filter }
      end
      it "should instantiate with processor" do
        FillEmUp::Origin.new(@arguments).filter.should be_a(FillEmUp::Filter)
        FillEmUp::Origin.new(@arguments).filter.should == @filter
      end
    end
  end

end
