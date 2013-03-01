require 'spec_helper'
describe FillEmUp::Pusher do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { FillEmUp::Pusher.new() }.to raise_error(ArgumentError)
      end
    end
    context "with arguments" do
      before :each do
        @filter = FillEmUp::Filter.new( -> (object) { object.is_a?(Numeric)} )
        @origin_queues = [
          FillEmUp::Result.new({  :name => "Top Results",
                                  :ratio => 0.4,
                                  :queue_ratios => {
                                    "High Price" => 0.2,
                                    "Medium Price" => 0.3,
                                    "Low Price" => 0.5 } }),
          FillEmUp::Result.new( {  :name => "Page Results",
                                   :ratio => 0.6,
                                   :queue_ratios => {
                                     "High Price" => 0.5,
                                     "Medium Price" => 0.3,
                                     "Low Price" => 0.2 } })
        ]
      end
      it "should not raise any errors" do
        expect { FillEmUp::Pusher.new(*@origin_queues) }.to_not raise_error
      end
      it "should instantiate with name" do
        popper = FillEmUp::Pusher.new(*@origin_queues)
        popper.queues.first.name.should == "Top Results"
        popper.queues.last.name.should == "Page Results"
      end
    end
  end

end
