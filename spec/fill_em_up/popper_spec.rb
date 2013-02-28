require 'spec_helper'
describe FillEmUp::Popper do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { FillEmUp::Popper.new() }.to raise_error(ArgumentError)
      end
    end
    context "with arguments" do
      before :each do
        @filter = FillEmUp::Filter.new( -> (object) { object.is_a?(Numeric)} )
        @origin_queues = [
          FillEmUp::Origin.new(
                                :name => "High Queue",
                                :elements => [1, 2, 3, 'c'],
                                :backfill => "Medium Queue",
                                :filter => @filter),
          FillEmUp::Origin.new( :name => "Medium Queue",
                                :elements => ['e', 'f', 4, 5],
                                :backfill => "Low Queue",
                                :filter => @filter),
          FillEmUp::Origin.new( :name => "Low Queue",
                                :elements => [7, 8, 'd'],
                                :backfill => nil,
                                :filter => @filter)
        ]
      end
      it "should not raise any errors" do
        expect { FillEmUp::Popper.new(*@origin_queues) }.to_not raise_error
      end
      it "should instantiate with name" do
        popper = FillEmUp::Popper.new(*@origin_queues)
        popper.queues.first.elements.should == [1,2,3,'c']
        popper.queues.last.elements.should == [7,8,'d']
      end
    end
  end

end
