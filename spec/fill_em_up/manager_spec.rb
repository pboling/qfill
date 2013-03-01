require 'spec_helper'
describe FillEmUp::Manager do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { FillEmUp::Manager.new() }.to raise_error(ArgumentError)
      end
    end
    context "with only popper" do
      it "should raise ArgumentError" do
        popper = FillEmUp::Popper.from_arary_of_hashes(
          [{ :name => "High Queue",
            :elements => [1,2,3]}] )
        expect { FillEmUp::Manager.new(:popper => popper) }.to raise_error(ArgumentError)
      end
    end
    context "with only pusher" do
      pusher = FillEmUp::Pusher.from_arary_of_hashes(
        [{ :name => "Some Result",
          :ratio => 0.25 }] )
      it "should raise ArgumentError" do
        expect { FillEmUp::Manager.new(:pusher => pusher) }.to raise_error(ArgumentError)
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
  end
end
