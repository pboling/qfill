require 'spec_helper'
describe Qfill::Result do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { Qfill::Result.new() }.to raise_error(ArgumentError)
      end
    end
    context "with name" do
      before :each do
        @arguments = { :name => "Best Results" }
      end
      it "should not raise any errors" do
        expect { Qfill::Result.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with name" do
        Qfill::Result.new(@arguments).name.should == 'Best Results'
      end
    end
    context "with ratio" do
      before :each do
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5 }
      end
      it "should instantiate with elements" do
        Qfill::Result.new(@arguments).ratio.should == 0.5
      end
    end
    context "with filter" do
      before :each do
        lambda = -> (object) { !object.nil? }
        @filter = Qfill::Filter.new(lambda)
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5,
                        :filter => @filter }
      end
      it "should instantiate with filter" do
        Qfill::Result.new(@arguments).filter.should be_a(Qfill::Filter)
        Qfill::Result.new(@arguments).filter.should == @filter
      end
    end
    context "with list_ratios" do
      before :each do
        @arguments = {  :name => "Best Results",
                        :ratio => 0.5,
                        :list_ratios => {
                          "High Price" => 0.4,
                          "Medium Price" => 0.3,
                          "Low Price" => 0.3 } }
      end
      it "should instantiate with elements" do
        Qfill::Result.new(@arguments).list_ratios["High Price"].should == 0.4
      end
    end
  end

end
