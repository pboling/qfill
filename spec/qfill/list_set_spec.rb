require 'spec_helper'
describe Qfill::ListSet do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { Qfill::ListSet.new() }.to raise_error(ArgumentError)
      end
    end
    context "with arguments" do
      before :each do
        @filter = Qfill::Filter.new( -> (object) { object.is_a?(Numeric)} )
        @origin_queues = [
          Qfill::List.new(
            :name => "High List",
            :elements => [1, 2, 3, 'c'],
            :filter => @filter),
          Qfill::List.new( :name => "Medium List",
                               :elements => ['e', 'f', 4, 5],
                               :filter => @filter),
          Qfill::List.new( :name => "Low List",
                               :elements => [7, 8, 'd'],
                               :filter => @filter)
        ]
      end
      it "should not raise any errors" do
        expect { Qfill::ListSet.new(*@origin_queues) }.to_not raise_error
      end
      it "should instantiate with name" do
        popper = Qfill::ListSet.new(*@origin_queues)
        popper.queues.first.elements.should == [1,2,3,'c']
        popper.queues.last.elements.should == [7,8,'d']
      end
    end
  end

end
