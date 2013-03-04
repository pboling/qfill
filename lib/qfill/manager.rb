#Qfill::Manager.new(
#  :all_list_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module Qfill
  class Manager
    attr_accessor :all_list_max, :popper, :pusher, :fill_count, :strategy

    STRATEGY_OPTIONS = [:drain, :sample]

    def initialize(options = {})
      unless options[:popper] && options[:pusher]
        raise ArgumentError, "#{self.class}: popper and pusher are required options for #{self.class}.new(options)"
      end
      unless options[:strategy].nil? || STRATEGY_OPTIONS.include?(options[:strategy])
        raise ArgumentError, "#{self.class}: strategy is optional, but must be one of #{STRATEGY_OPTIONS.inspect} if provided"
      end
      @popper = options[:popper]
      @pusher = options[:pusher]
      # Provided by user, or defaults to the total number of primary elements in popper list set
      @all_list_max = options[:all_list_max] ? [options[:all_list_max], self.popper.get_primary_elements].min : self.popper.get_primary_elements
      @fill_count = 0
      @strategy = options[:strategy] || :drain # or :sample
    end

    def fill!
      while !is_full? && !self.popper.primary_empty? && (result = self.pusher.current_list)
        self.fill_to_ratio!(result, self.all_list_max)
        self.pusher.set_next_as_current!
      end
    end

    def fill_to_ratio!(result, all_list_max)
      result.max = Qfill::Result.get_limit_from_max_and_ratio(all_list_max, result.ratio)
      if !result.list_ratios.empty?
        self.fill_according_to_list_ratios!(result)
      else
        self.fill_up_to_ratio!(result)
      end
    end

    def fill_according_to_list_ratios!(result)
      added = 0
      if self.strategy == :drain
        result.list_ratios.each do |list_name, list_ratio|
          #puts "fill_according_to_list_ratios!, :drain, #{list_name}: Primary remaining => #{self.popper.get_primary_elements}"
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio)
          array_to_push = self.popper.next_objects!(list_name, max_from_list)
          added = result.push(array_to_push, list_name)
        end
        self.fill_count += added
      elsif self.strategy == :sample
        while !is_full? && !result.is_full? && !self.popper.totally_empty? && (list_ratio_tuple = result.current_list_ratio)
          #puts "fill_according_to_list_ratios!, :sample, #{list_ratio_tuple[0]}: Primary remaining => #{self.popper.get_primary_elements}"
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio_tuple[1])
          array_to_push = self.popper.next_objects!(list_ratio_tuple[0], max_from_list)
          added = result.push(array_to_push, list_ratio_tuple[0])
          self.fill_count += added
          result.set_next_as_current!
        end
      end
    end

    def fill_up_to_ratio!(result)
      ratio = 1.0 / self.popper.primary.length
      max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio)
      added = 0
      if self.strategy == :drain
        self.popper.primary.each do |queue|
          #puts "fill_up_to_ratio!, :drain max #{max_from_list}, #{queue.name}: Primary remaining => #{self.popper.get_primary_elements}"
          array_to_push = self.popper.next_objects!(queue.name, max_from_list)
          added = result.push(array_to_push, queue.name)
        end
        self.fill_count += added
      elsif self.strategy == :sample
        while !is_full? && !result.is_full? && !self.popper.totally_empty? && (origin_list = self.popper.current_list)
          #puts "fill_up_to_ratio!, :sample max #{max_from_list}, #{origin_list.name}: Primary remaining => #{self.popper.get_primary_elements}"
          array_to_push = self.popper.next_objects!(origin_list.name, max_from_list)
          added = result.push(array_to_push, origin_list.name)
          self.fill_count += added
          self.popper.set_next_as_current!
        end
      end
    end

    def is_full?
      self.fill_count >= self.all_list_max
    end
  end
end
