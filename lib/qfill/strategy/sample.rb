# frozen_string_literal: true

module Qfill
  module Strategy
    class Sample < Qfill::Strategy::Base
      NAME = :sample

      def on_fill!
        # NOOP
      end

      def result_max!
        result.max = Qfill::Result.get_limit_from_max_and_ratio(primary_list_total, result.ratio, remaining)
      end

      def fill_up_to_ratio!
        ratio = 1.0 / popper.primary.length # 1 divided by the number of queues
        max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio, remaining)
        while !is_full? && !result.is_full? && !popper.totally_empty? && (origin_list = popper.current_list)
          array_to_push = popper.next_objects!(origin_list.name, [max_from_list, remaining].min)
          self.added = result.push(array_to_push, origin_list.name)
          bump!
          puts "[fill_up_to_ratio!]#{self}[Added:#{added}][Max List:#{max_from_list}][ratio:#{ratio}][added:#{added}]" if Qfill::VERBOSE
          popper.set_next_as_current!
        end
      end

      def fill_according_to_list_ratios!
        # puts "#{!is_full?} && #{result.fill_count} >= #{result.max} && #{!self.popper.totally_empty?} && #{(list_ratio_tuple = result.current_list_ratio)}"
        while !is_full? && !result.is_full? && !popper.totally_empty? && (list_ratio_tuple = result.current_list_ratio)
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio_tuple[1], remaining)
          array_to_push = popper.next_objects!(list_ratio_tuple[0], max_from_list)
          self.added = result.push(array_to_push, list_ratio_tuple[0])
          bump!
          puts "[fill_according_to_list_ratios!]#{self}[#{list_ratio_tuple[0]}][added:#{added}]" if Qfill::VERBOSE
          result.set_next_as_current!
          break if is_full?
        end
      end
    end
  end
end
