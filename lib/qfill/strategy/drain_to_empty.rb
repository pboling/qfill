# frozen_string_literal: true

module Qfill
  module Strategy
    class DrainToEmpty < Qfill::Strategy::Base
      NAME = :drain_to_empty

      def on_fill!
        preferred_potential_ratio = 0
        preferred_potential = 0
        result.list_ratios.each do |list_name, list_ratio|
          poppy = result.preferred.select { |x| x == list_name }
          next unless poppy

          preferred_potential_ratio += list_ratio
          num = popper[list_name].elements.length
          preferred_potential += num
          result.max_tracker[list_name] = num
        end
        result.preferred_potential = preferred_potential
        result.preferred_potential_ratio = preferred_potential_ratio
      end

      def result_max!
        result.max = if result.preferred_potential_ratio.positive?
                       [
                         (result.preferred_potential / result.preferred_potential_ratio),
                         primary_list_total,
                         remaining
                       ].min
                     else
                       [
                         primary_list_total,
                         remaining
                       ].min
                     end
      end

      def fill_up_to_ratio!
        popper.primary.each do |queue|
          array_to_push = popper.next_objects!(queue.name, [result.max, remaining].min)
          self.added = result.push(array_to_push, queue.name)
          popper.current_index = popper.index_of(queue.name)
          bump!
          puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}][added:#{added}]" if Qfill::VERBOSE
          break if is_full?
        end
      end

      def fill_according_to_list_ratios!
        # Are there any elements in preferred queues that we should add?
        return unless result.preferred_potential.positive?

        # Setup a ratio modifier for the non-preferred queues
        result.list_ratios.each do |list_name, list_ratio|
          max_from_list = if result.max_tracker[list_name]
                            [result.max_tracker[list_name], remaining].min
                          else
                            Qfill::Result.get_limit_from_max_and_ratio(
                              result.max, list_ratio, remaining
                            )
                          end
          array_to_push = popper.next_objects!(list_name, max_from_list)
          self.added = result.push(array_to_push, list_name)
          popper.current_index = popper.index_of(list_name)
          bump!
          puts "[fill_according_to_list_ratios!]#{self}[#{list_name}][added:#{added}]" if Qfill::VERBOSE
          break if is_full?
        end
      end
    end
  end
end
