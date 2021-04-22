# frozen_string_literal: true

require 'forwardable'

module Qfill
  module Strategy
    class Base
      extend Forwardable
      def_delegators :@manager,
                     :all_list_max,
                     :popper,
                     :pusher,
                     :result,
                     :primary_list_total,
                     :fill_count,
                     :fill_count=,
                     :is_full?,
                     :strategy_options
      attr_accessor :added,
                    :tally,
                    :ratio_modifier

      def initialize(manager)
        @manager = manager
        @added = 0
        @tally = 0
        @ratio_modifier = 1
      end

      def name
        NAME
      end

      def on_fill!
        raise NotImplementedError
      end

      def fill_to_ratio!
        raise NotImplementedError
      end

      # Go through the queues this result should be filled from and push elements from them onto the current result list.
      def fill_according_to_list_ratios!
        raise NotImplementedError
      end

      def fill_up_to_ratio!
        raise NotImplementedError
      end

      def default_pusher
        # NOOP
      end

      def bump!
        self.tally += added
        self.fill_count += added
      end

      def remaining
        all_list_max - fill_count
      end
    end
  end
end
