require 'spec_helper'
describe FillEmUp::Result do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { FillEmUp::Result.new() }.to raise_error(ArgumentError)
      end
    end
    context "with name" do
      before :each do
        @arguments = { :name => "Best Results" }
      end
      it "should not raise any errors" do
        expect { FillEmUp::Result.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with name" do
        FillEmUp::Result.new(@arguments).name.should == 'Best Results'
      end
    end
    context "with ratio" do
      before :each do
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5 }
      end
      it "should instantiate with elements" do
        FillEmUp::Result.new(@arguments).ratio.should == 0.5
      end
    end
    context "with filter" do
      before :each do
        lambda = -> (object) { !object.nil? }
        @filter = FillEmUp::Filter.new(lambda)
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5,
                        :filter => @filter }
      end
      it "should instantiate with filter" do
        FillEmUp::Result.new(@arguments).filter.should be_a(FillEmUp::Filter)
        FillEmUp::Result.new(@arguments).filter.should == @filter
      end
    end
    context "with queue_ratios" do
      before :each do
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5,
                        :queue_ratios => {
                          "High Price" => 0.4,
                          "Medium Price" => 0.3,
                          "Low Price" => 0.3 } }
      end
      it "should instantiate with elements" do
        FillEmUp::Result.new(@arguments).queue_ratios["High Price"].should == 0.4
      end
    end
  end

end
