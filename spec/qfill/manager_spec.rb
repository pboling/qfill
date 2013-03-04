require 'spec_helper'
describe Qfill::Manager do
  context "#new" do
    context "with no arguments" do
      it "should raise ArgumentError" do
        expect { Qfill::Manager.new() }.to raise_error(ArgumentError)
      end
    end
    context "with only popper" do
      it "should raise ArgumentError" do
        popper = Qfill::Popper.from_array_of_hashes(
          [{ :name => "High List",
            :elements => [1,2,3]}] )
        expect { Qfill::Manager.new(:popper => popper) }.to raise_error(ArgumentError)
      end
    end
    context "with only pusher" do
      it "should raise ArgumentError" do
        pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "Some Result",
             :ratio => 0.25 }] )
        expect { Qfill::Manager.new(:pusher => pusher) }.to raise_error(ArgumentError)
      end
    end
    context "with popper and pusher" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          [{ :name => "High List",
             :elements => [1,2,3]}] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "Some Result",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper
        }
      end
      it "should not raise any errors" do
        expect { Qfill::Manager.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with pusher" do
        Qfill::Manager.new(@arguments).pusher.should == @pusher
      end
      it "should instantiate with popper" do
        Qfill::Manager.new(@arguments).popper.should == @popper
      end
    end
    context "with popper and pusher and all_list_max smaller than # total elements" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          [{ :name => "High List",
             :elements => [1,2,3]}] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "Some Result",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 2
        }
      end
      it "should not raise any errors" do
        expect { Qfill::Manager.new(@arguments) }.to_not raise_error
      end
      it "should instantiate with pusher" do
        Qfill::Manager.new(@arguments).pusher.should == @pusher
      end
      it "should instantiate with popper" do
        Qfill::Manager.new(@arguments).popper.should == @popper
      end
      it "should instantiate with all_list_max" do
        Qfill::Manager.new(@arguments).all_list_max.should == 2
      end
    end
    context "all_list_max greater than # total elements" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          [{ :name => "High List",
             :elements => [1,2,3]}] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "Some Result",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 666
        }
      end
      it "should instantiate with all_list_max" do
        Qfill::Manager.new(@arguments).all_list_max.should == 3
      end
    end
  end
  context "strategy => :sample" do
    context "backfill => false" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{:name => 'high',
            :elements => %w( h1 h2 h3 h4 h5 h6 h7 h8 h9 ),
            :backfill => 'medium'},
           {:name => "medium",
            :elements => %w( m1 m2 m3 m4 m5 m6 m7 m8 m9 ),
            :backfill => 'none'},
           {:name => 'low',
            :elements => %w( l1 l2 l3 l4 l5 l6 l7 l8 l9 ),
            :backfill => false},
           {:name => 'none',
            :elements => %w( n1 n2 n3 n4 n5 n6 n7 n8 n9 ),
            :backfill => 'low' }] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "first",
             :list_ratios => {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             :ratio => 0.25 },
           { :name => "second",
             :ratio => 0.50 },
           { :name => "third",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 40,
          :strategy => :sample
        }
      end
      context "#new" do
        it "should not raise any errors" do
          expect { Qfill::Manager.new(@arguments) }.to_not raise_error
        end
      end
      context "#fill!" do
        it "should instantiate with pusher" do
          expect { Qfill::Manager.new(@arguments).fill!  }.to_not raise_error
        end
      end
      context "results" do
        before(:each) do
          @manager = Qfill::Manager.new(@arguments)
        end
        context "before fill!" do
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 36
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 36
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 0
          end
        end
        context "after fill!" do
          before(:each) do
            @manager.fill!
          end
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 0
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 0
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 36
          end
        end
      end
    end
    context "backfill => true" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{:name => 'high',
            :elements => %w( h1 h2 h3 h4 h5 h6 h7 h8 h9 ),
            :backfill => 'medium'},
           {:name => "medium",
            :elements => %w( m1 m2 m3 m4 m5 m6 m7 m8 m9 ),
            :backfill => 'none'},
           {:name => 'low',
            :elements => %w( l1 l2 l3 l4 l5 l6 l7 l8 l9 ),
            :backfill => true},
           {:name => 'none',
            :elements => %w( n1 n2 n3 n4 n5 n6 n7 n8 n9 ),
            :backfill => 'low' }] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "first",
             :list_ratios => {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             :ratio => 0.25 },
           { :name => "second",
             :ratio => 0.50 },
           { :name => "third",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 40,
          :strategy => :sample
        }
      end
      context "#new" do
        it "should not raise any errors" do
          expect { Qfill::Manager.new(@arguments) }.to_not raise_error
        end
      end
      context "#fill!" do
        it "should instantiate with pusher" do
          expect { Qfill::Manager.new(@arguments).fill!  }.to_not raise_error
        end
      end
      context "results" do
        before(:each) do
          @manager = Qfill::Manager.new(@arguments)
        end
        context "before fill!" do
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 36
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 27
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 0
          end
        end
        context "after fill!" do
          before(:each) do
            @manager.fill!
          end
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 9
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 0
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 27
          end
        end
      end
    end
  end
  context "strategy :drain" do
    context "backfill => false" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{:name => 'high',
            :elements => %w( h1 h2 h3 h4 h5 h6 h7 h8 h9 ),
            :backfill => 'medium'},
           {:name => "medium",
            :elements => %w( m1 m2 m3 m4 m5 m6 m7 m8 m9 ),
            :backfill => 'none'},
           {:name => 'low',
            :elements => %w( l1 l2 l3 l4 l5 l6 l7 l8 l9 ),
            :backfill => false},
           {:name => 'none',
            :elements => %w( n1 n2 n3 n4 n5 n6 n7 n8 n9 ),
            :backfill => 'low' }] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "first",
             :list_ratios => {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             :ratio => 0.25 },
           { :name => "second",
             :ratio => 0.50 },
           { :name => "third",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 40,
          :strategy => :drain
        }
      end
      context "#new" do
        it "should not raise any errors" do
          expect { Qfill::Manager.new(@arguments) }.to_not raise_error
        end
      end
      context "#fill!" do
        it "should instantiate with pusher" do
          expect { Qfill::Manager.new(@arguments).fill!  }.to_not raise_error
        end
      end
      context "results" do
        before(:each) do
          @manager = Qfill::Manager.new(@arguments)
        end
        context "before fill!" do
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 36
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 36
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 0
          end
        end
        context "after fill!" do
          before(:each) do
            @manager.fill!
          end
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 0 # With drain the results do not exactly match the requested ratios.
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 0
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 36
          end
        end
      end
    end
    context "backfill => true" do
      before :each do
        @popper = Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{:name => 'high',
            :elements => %w( h1 h2 h3 h4 h5 h6 h7 h8 h9 ),
            :backfill => 'medium'},
           {:name => "medium",
            :elements => %w( m1 m2 m3 m4 m5 m6 m7 m8 m9 ),
            :backfill => 'none'},
           {:name => 'low',
            :elements => %w( l1 l2 l3 l4 l5 l6 l7 l8 l9 ),
            :backfill => true},
           {:name => 'none',
            :elements => %w( n1 n2 n3 n4 n5 n6 n7 n8 n9 ),
            :backfill => 'low' }] )
        @pusher = Qfill::Pusher.from_array_of_hashes(
          [{ :name => "first",
             :list_ratios => {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             :ratio => 0.25 },
           { :name => "second",
             :ratio => 0.50 },
           { :name => "third",
             :ratio => 0.25 }] )
        @arguments = {
          :pusher => @pusher,
          :popper => @popper,
          :all_list_max => 40,
          :strategy => :drain
        }
      end
      context "#new" do
        it "should not raise any errors" do
          expect { Qfill::Manager.new(@arguments) }.to_not raise_error
        end
      end
      context "#fill!" do
        it "should instantiate with pusher" do
          expect { Qfill::Manager.new(@arguments).fill!  }.to_not raise_error
        end
      end
      context "results" do
        before(:each) do
          @manager = Qfill::Manager.new(@arguments)
        end
        context "before fill!" do
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 36
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 27
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 0
          end
        end
        context "after fill!" do
          before(:each) do
            @manager.fill!
          end
          it "should calculate the correct popper total elements" do
            @manager.popper.get_total_elements.should == 7 # With drain the results do not exactly match the requested ratios.
          end
          it "should calculate the correct popper primary elements" do
            @manager.popper.get_primary_elements == 0
          end
          it "should calculate the correct pusher total elements" do
            @manager.pusher.get_total_elements.should == 29
          end
        end
      end
    end
  end
end
