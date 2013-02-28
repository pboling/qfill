require 'spec_helper'
describe FillEmUp::Filter do
  context "#new" do
    context "with processor" do
      before :each do
        @lambda = -> (object) { !object.nil? }
      end
      it "should instantiate with processor" do
        FillEmUp::Filter.new(@lambda).should be_a(FillEmUp::Filter)
      end
    end

    context "with processor and arguments" do
      before :each do
        @lambda = -> (object, first, second) { !object.nil? && first == first && second == 'second' }
        @arguments = ['first','second']
      end
      it "should instantiate with processor" do
        FillEmUp::Filter.new(@lambda, *@arguments).should be_a(FillEmUp::Filter)
      end
    end
  end

  context "#run" do
    before :each do
      @lambda = -> (object, first, second) { !object.nil? && first == first && second == 'second' }
      @arguments = ['first','second']
      @filter = FillEmUp::Filter.new(@lambda, *@arguments)
    end
    it "should return the correct result" do
      @filter.run('not nil').should == true
    end
    context "with extra arguments" do
      before :each do
        @lambda = -> (object, special_arg1, special_arg2, first, second, third) { !object.nil? && first == first && second == 'second' && special_arg1 = 'this' && special_arg2 == 'thing' && third == 'third' }
        @arguments = ['first','second','third']
        @filter = FillEmUp::Filter.new(@lambda, *@arguments)
      end
      it "should properly use arity" do
        @filter.run('not nil', 'this', 'thing').should == true
      end
    end
  end
end
