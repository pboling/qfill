# frozen_string_literal: true

module Qfill
  module Strategy
    class DrainToLimit < Qfill::Strategy::Base
      NAME = :drain_to_limit
      def name
        NAME
      end

      def on_fill!
        # NOOP
      end

      def result_max!
        result.max = Qfill::Result.get_limit_from_max_and_ratio(primary_list_total, result.ratio, remaining)
      end

      def fill_up_to_ratio!
        num_primary = popper.primary.length
        ratio = 1.0 / num_primary # 1 divided by the number of queues
        max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio, remaining)
        popper.primary.each_with_index do |queue, idx|
          # Are there leftovers that will be missed by a straight ratio'd iteration?
          mod = result.max % num_primary
          max_from_list += (mod / num_primary).ceil if idx.zero? && mod.positive?
          array_to_push = popper.next_objects!(queue.name, [max_from_list, remaining].min)
          self.added = result.push(array_to_push, queue.name)
          popper.current_index = popper.index_of(queue.name)
          puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}][added:#{added}]" if Qfill::VERBOSE
          bump!
          break if is_full?
        end
      end

      def fill_according_to_list_ratios!
        result.list_ratios.each do |list_name, list_ratio|
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio, remaining)
          array_to_push = popper.next_objects!(list_name, max_from_list)
          self.added = result.push(array_to_push, list_name)
          popper.current_index = popper.index_of(list_name)
          puts "[fill_according_to_list_ratios!]#{self}[#{list_name}][added:#{added}]" if Qfill::VERBOSE
          bump!
          break if is_full?
        end
      end
    end
  end
end
