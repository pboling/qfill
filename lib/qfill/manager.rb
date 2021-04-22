# frozen_string_literal: true

require 'forwardable'

# A Qfill::Manager builds a set of result data (as `result`) from the source data in Qfill::Popper,
#   according to the Qfill::Result definitions in the Qfill::Pusher, and the selected strategy.
#
# Qfill::Manager.new(
#  :all_list_max => 40,
#  :popper => popper,
#  :pusher => pusher,
# )
module Qfill
  class Manager
    extend Forwardable
    def_delegators :@strategy, :popper, :pusher, :result, :remaining_to_fill
    attr_accessor :all_list_max, :primary_list_total, :popper, :pusher, :fill_count, :result

    STRATEGY_OPTIONS = %i[drain_to_limit drain_to_empty sample].freeze

    def initialize(options = {})
      unless options[:popper] && options[:pusher]
        raise ArgumentError, "#{self.class}: popper and pusher are required options for #{self.class}.new(options)"
      end

      unless options[:strategy].nil? || STRATEGY_OPTIONS.include?(options[:strategy])
        raise ArgumentError,
              "#{self.class}: strategy is optional, but must be one of #{STRATEGY_OPTIONS.inspect} if provided"
      end

      @popper = options[:popper]
      @pusher = options[:pusher]
      # Provided by user, or defaults to the total number of elements in popper list set
      @all_list_max = if options[:all_list_max]
                        [options[:all_list_max],
                         popper.count_all_elements].min
                      else
                        popper.count_all_elements
                      end
      @primary_list_total = popper.count_primary_elements
      @fill_count = 0
      @strategy_name = options[:strategy] || :drain_to_limit # or :drain_to_empty or :sample
    end

    def strategy
      @strategy ||= case @strategy_name
                    when :drain_to_empty
                      Qfill::Strategy::DrainToEmpty.new(self)
                    when :drain_to_limit
                      Qfill::Strategy::DrainToLimit.new(self)
                    when :sample
                      Qfill::Strategy::Sample.new(self)
                    end
    end

    def fill!
      while !is_full? && !popper.primary_empty? && (self.result = pusher.current_list)
        strategy.on_fill!
        fill_to_ratio!
        pusher.set_next_as_current!
        result.elements.shuffle! if result.shuffle
      end
    end

    def fill_to_ratio!
      strategy.result_max!
      if result.list_ratios.empty?
        fill_up_to_ratio!
      else
        fill_according_to_list_ratios!
      end
    end

    def remaining_to_fill
      primary_list_total - fill_count
    end

    # Go through the queues this result should be filled from and push elements from them onto the current result list.
    def fill_according_to_list_ratios!
      strategy.fill_according_to_list_ratios!
    end

    # Go through the primary (non backfill) queues in the popper and push elements from them onto the current result list.
    def fill_up_to_ratio!
      strategy.fill_up_to_ratio!
    end

    def is_full?
      fill_count >= all_list_max
    end

    def to_s
      "[#{strategy_name}][Result Max:#{result.max}][All Max:#{all_list_max}][Current Max:#{result.max}][Filled:#{fill_count}][Primary #:#{popper.count_primary_elements}]"
    end
  end
end
