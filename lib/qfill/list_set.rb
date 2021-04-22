# frozen_string_literal: true

# This is the base queues class for Popper queues and Pusher queues.
#
# popper = Qfill::ListSet.new(
#  Qfill::List.new( :name => "High List",
#                       :elements => [Thing1, Thing3],
#                       :filter => filter1 ) )
module Qfill
  class ListSet
    attr_accessor :queues, :current_index

    def initialize(*args)
      raise ArgumentError, "Missing required arguments for #{self.class}.new(queues)" unless args.length.positive?

      @queues = args
      @current_index = 0
    end

    def [](key)
      queues.find { |queue| queue.name == key }
    end

    def index_of(queue_name)
      index = queues.index { |queue| queue.name == queue_name }
      return index if index

      raise Qfill::Errors::InvalidIndex, "Cannot locate index of #{queue_name}"
    end

    def reset!
      self.current_index = 0
    end

    def count_all_elements
      queues.inject(0) { |counter, queue| counter += queue.elements.length }
    end
  end
end
