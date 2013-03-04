require 'spec_helper'
describe Qfill::Popper do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { Qfill::Popper.new() }.to raise_error(ArgumentError)
      end
    end
    context "with arguments" do
      before :each do
        @filter = Qfill::Filter.new( -> (object) { object.is_a?(Numeric)} )
        @origin_queues = [
          Qfill::Origin.new(
                                :name => "High List",
                                :elements => [1, 2, 3, 'c'],
                                :backfill => "Medium List",
                                :filter => @filter),
          Qfill::Origin.new( :name => "Medium List",
                                :elements => ['e', 'f', 4, 5],
                                :backfill => "Low List",
                                :filter => @filter),
          Qfill::Origin.new( :name => "Low List",
                                :elements => [7, 8, 'd'],
                                :backfill => nil,
                                :filter => @filter)
        ]
      end
      it "should not raise any errors" do
        expect { Qfill::Popper.new(*@origin_queues) }.to_not raise_error
      end
      it "should instantiate with name" do
        popper = Qfill::Popper.new(*@origin_queues)
        popper.queues.first.name.should == "High List"
        popper.queues.last.name.should == "Low List"
      end
      it "should instantiate with elements" do
        popper = Qfill::Popper.new(*@origin_queues)
        popper.queues.first.elements.should == [1,2,3,'c']
        popper.queues.last.elements.should == [7,8,'d']
      end
    end
  end

end
