# Qfill

This gem takes a dynamic number of queues (arrays) of things, and manages the transformation into a new set of queues,
according to a dynamic set of guidelines.

## Installation

Add this line to your application's Gemfile:

    gem 'qfill'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qfill

## Usage & List Fill Methodology

There will be a dynamic number of origination queues each containing a set of snapshots which are grouped together by
some matching criteria.
There is a Popper which is called to pop the next object from the next origination queue.
There is a Filter which is optionally called to validate any object that is popped from the origin.
Origin keeps popping until an object is validated for as a result-worthy object.

Example:

    filter1 = Qfill::Filter.new( -> (object, stuff, stank) { object.is_awesome_enough_to_be_in_results?(stuff, stank) }, stuff, stank)
    filter2 = Qfill::Filter.new( -> (object, rank, bank) { object.is_awesome_enough_to_be_in_results?(rank, bank) }, rank, bank)

    popper = Qfill::Popper.new(
      Qfill::Origin.new( :name => "High List",
                            :elements => [Thing1, Thing3],
                            :backfill => "Medium List",
                            :filter => filter1),
      Qfill::Origin.new( :name => "Medium List",
                            :elements => [Thing2, Thing6],
                            :backfill => "Low List",
                            :filter => filter2),
      Qfill::Origin.new( :name => "Low List",
                            :elements => [Thing4, Thing5],
                            :backfill => nil,
                            :filter => filter1),
    )

Or:

    popper = Qfill::Popper.from_hash(
      { :name => "High List",
        :elements => [Thing1, Thing3, Thing7, Thing8, Thing12, Thing15, Thing17],
        :backfill => "Medium List",
        :filter => filter1},
      { :name => "Medium List",
        :elements => [Thing2, Thing6, Thing11, Thing 16],
        :backfill => "Low List",
        :filter => filter2},
      { :name => "Low List",
        :elements => [Thing4, Thing5, Thing9, Thing10, Thing13, Thing14, Thing18, Thing19, Thing20],
        :backfill => nil,
        :filter => filter1},
    )

There are a dynamic number of result queues that need to be filled with objects from the origination queues.
There is a Pusher which is called to add the object from the Popper to the next result queue.
A filter can be given to perform additional check to verify that the object should be added to a particular result queue.
At least one result queue should be left with no filter, or you risk a result set that is completely empty.
A filter_alternate can be given to indicate which alternate result queue objects failing the filter should be placed in.
A ratio can be given to indicate the portion of the total results which should go into the result queue.
A set of queue ratios can be defined to indicate the rate at which the result queue will be filled from each origin queue.
When queue ratios are not given an even split is assumed.

Example:

    filter3 = Qfill::Filter.new( -> (object, stuff, stank) { object.can_be_best_results?(stuff, stank) }, stuff, stank)

    pusher = Qfill::Pusher.new(
      Qfill::Result.new( :name => "Best Results",
                            :filter => filter3,
                            :ratio => 0.5,
                            :list_ratios => {
                              "High List" => 0.4,
                              "Medium List" => 0.2,
                              "Low List" => 0.4
                            }
                          ),
      Qfill::Result.new( :name => "More Results",
                            :ratio => 0.5,
                            :list_ratios => {
                              "High List" => 0.2,
                              "Medium List" => 0.4,
                              "Low List" => 0.4
                            }
      )
    )

Or:

    pusher = Qfill::Pusher.from_hash(
      { :name => "First Result",
        :ratio => 0.125,
        :filter => filter3,
        :ratios => {
          "High List" => 0.4,
          "Medium List" => 0.2,
          "Low List" => 0.4
        }
      },
      { :name => "Second Result",
        :ratio => 0.25 },
      { :name => "Third Result",
        :ratio => 0.125 },
      { :name => "Fourth Result",
        :ratio => 0.50 },
    )

There is a Manager which maintains state: always knows which queue to pop from next, and which queue to push onto next.

    Qfill::Manager.new(
      :all_list_max => 40,
      :popper => popper,
      :pusher => pusher,
    )

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
