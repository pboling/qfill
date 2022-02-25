# frozen_string_literal: true

module Qfill
  module Strategy
    # Qfill::Manager.new(
    #   :popper => popper,
    #   :strategy_options => {
    #     :window_size => 20,
    #     :window_units => "minutes" # "days", "hours", "minutes", "seconds",
    #     # NOTE: pane_size/units can't be larger than the window_size/units
    #     :pane_size => 2
    #     :pane_units => "seconds" # "days", "hours", "minutes", "seconds",
    #   },
    # )
    class TimeSlice < Qfill::Strategy::Sample
      NAME = :time_slice

      def on_fill!
        # NOOP
      end

      CONVERSIONS = {
        %w[seconds seconds] => 1,
        %w[seconds minutes] => 60,
        %w[seconds hours] => 60 * 60,
        %w[seconds days] => 60 * 60 * 24,
        %w[minutes minutes] => 1,
        %w[minutes hours] => 60,
        %w[minutes days] => 60 * 24,
        %w[hours hours] => 1,
        %w[hours days] => 24,
        %w[days days] => 1
      }.freeze

      # If window_units == "minutes" and pane_units == "seconds", and
      #    window_size == 20 and pane_size == 2
      # Then there would be (20 * CONVERSIONS[[pane_units, window_units]]) / pane_size
      #   i.e.              (20 * 60) / 2
      #   i.e.              600 individual panes in the (time) window, where each pane is a "result"
      def default_pusher
        ratio = 1 / num_panes.to_f
        array = Range.new(1, num_panes).each_with_object([]) do |pane_num, arr|
          arr << { name: pane_num.to_s, ratio: ratio }
        end
        Qfill::Pusher.from_array_of_hashes(array)
      end

      def window_size
        strategy_options[:window_size]
      end

      def window_units
        strategy_options[:window_units]
      end

      def pane_size
        strategy_options[:pane_size]
      end

      def pane_units
        strategy_options[:pane_units]
      end

      def conversion
        conversion_idx = [pane_units, window_units]
        conv = CONVERSIONS[conversion_idx]
        raise ArgumentError, "pane_units: #{pane_units} must not be larger than window_units: #{window_units}" unless conv

        conv
      end

      def num_panes
        ((window_size * conversion) / pane_size)
      end

      def result_max!
        result.max = Qfill::Result.get_limit_from_max_and_ratio(primary_list_total, result.ratio, remaining)
      end

      def fill_up_to_ratio!
        ratio = 1.0 / popper.primary.length # 1 divided by the number of queues
        max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio, remaining)
        while !is_full? && (take = [max_from_list, remaining].min) && (!result.is_full? || take == 1) && !popper.totally_empty? && (origin_list = popper.current_list)
          array_to_push = popper.next_objects!(origin_list.name, take)
          self.added = result.push(array_to_push, origin_list.name)
          bump!
          puts "[fill_up_to_ratio!]#{self}[Added:#{added}][Max List:#{max_from_list}][ratio:#{ratio}][take:#{take}]" if Qfill::VERBOSE
          popper.set_next_as_current!
        end
      end

      def fill_according_to_list_ratios!
        # puts "#{!is_full?} && #{result.fill_count} >= #{result.max} && #{!self.popper.totally_empty?} && #{result.current_list_ratio}"
        while !is_full? && !popper.totally_empty? && (list_ratio_tuple = result.current_list_ratio) && (take = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio_tuple[1], remaining)) && (!result.is_full? || take == 1)
          array_to_push = popper.next_objects!(list_ratio_tuple[0], take)
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
