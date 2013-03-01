require 'spec_helper'
describe FillEmUp::QueueSet do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { FillEmUp::QueueSet.new() }.to raise_error(ArgumentError)
      end
    end
    context "with arguments" do
      before :each do
        @filter = FillEmUp::Filter.new( -> (object) { object.is_a?(Numeric)} )
        @origin_queues = [
          FillEmUp::Queue.new(
            :name => "High Queue",
            :elements => [1, 2, 3, 'c'],
            :filter => @filter),
          FillEmUp::Queue.new( :name => "Medium Queue",
                               :elements => ['e', 'f', 4, 5],
                               :filter => @filter),
          FillEmUp::Queue.new( :name => "Low Queue",
                               :elements => [7, 8, 'd'],
                               :filter => @filter)
        ]
      end
      it "should not raise any errors" do
        expect { FillEmUp::QueueSet.new(*@origin_queues) }.to_not raise_error
      end
      it "should instantiate with name" do
        popper = FillEmUp::QueueSet.new(*@origin_queues)
        popper.queues.first.elements.should == [1,2,3,'c']
        popper.queues.last.elements.should == [7,8,'d']
      end
    end
  end

end
