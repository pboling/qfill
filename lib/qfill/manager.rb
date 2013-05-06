#Qfill::Manager.new(
#  :all_list_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module Qfill
  class Manager
    attr_accessor :all_list_max, :popper, :pusher, :fill_count, :strategy, :result

    STRATEGY_OPTIONS = [:drain_to_limit, :drain_to_fill, :sample]

    def initialize(options = {})
      unless options[:popper] && options[:pusher]
        raise ArgumentError, "#{self.class}: popper and pusher are required options for #{self.class}.new(options)"
      end
      unless options[:strategy].nil? || STRATEGY_OPTIONS.include?(options[:strategy])
        if options[:strategy] == :drain
          warn "Qfill strategy :drain has been renamed :drain_to_limit, please update your code."
          options[:strategy] = :drain_to_limit
        else
          raise ArgumentError, "#{self.class}: strategy is optional, but must be one of #{STRATEGY_OPTIONS.inspect} if provided"
        end
      end
      @popper = options[:popper]
      @pusher = options[:pusher]
      # Provided by user, or defaults to the total number of primary elements in popper list set
      @all_list_max = options[:all_list_max] ? [options[:all_list_max], self.popper.count_primary_elements].min : self.popper.count_primary_elements
      @current_list_max = options[:current_list_max] ? [options[:current_list_max], self.popper.count_current_elements].min : self.popper.count_current_elements
      @fill_count = 0
      @strategy = options[:strategy] || :drain_to_limit # or :sample
    end

    def fill!
      while !is_full? && !self.popper.primary_empty? && (self.result = self.pusher.current_list)
        self.fill_to_ratio!
        self.pusher.set_next_as_current!
      end
    end

    def fill_to_ratio!
      case self.strategy
        when :drain_to_fill then
          result.max = Qfill::Result.get_limit_from_max_and_ratio(self.current_list_max, result.ratio)
        when :drain_to_limit then
          result.max = Qfill::Result.get_limit_from_max_and_ratio(self.all_list_max, result.ratio)
        when :sample then
          result.max = Qfill::Result.get_limit_from_max_and_ratio(self.all_list_max, result.ratio)
      end
      if !result.list_ratios.empty?
        self.fill_according_to_list_ratios!
      else
        self.fill_up_to_ratio!
      end
    end

    # Go through the queues this result should be filled from and push elements from them onto the current result list.
    def fill_according_to_list_ratios!
      added = 0
      case self.strategy
        when :drain_to_fill, :drain_to_limit then
        result.list_ratios.each do |list_name, list_ratio|
          puts "[fill_according_to_list_ratios!]#{self}[#{list_name}]" if Qfill::VERBOSE
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio)
          array_to_push = self.popper.next_objects!(list_name, max_from_list)
          added = result.push(array_to_push, list_name)
        end
        self.fill_count += added
      when :sample then
        while !is_full? && !result.is_full? && !self.popper.totally_empty? && (list_ratio_tuple = result.current_list_ratio)
          puts "[fill_according_to_list_ratios!]#{self}[#{list_ratio_tuple[0]}]" if Qfill::VERBOSE
          max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio_tuple[1])
          array_to_push = self.popper.next_objects!(list_ratio_tuple[0], max_from_list)
          added = result.push(array_to_push, list_ratio_tuple[0])
          self.fill_count += added
          result.set_next_as_current!
        end
      end
    end

    # Go through the primary (non backfill) queues in the popper and push elements from them onto the current result list.
    def fill_up_to_ratio!
      added = 0
      if self.strategy == :drain_to_fill
        self.popper.primary.each do |queue|
          puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}]" if Qfill::VERBOSE
          array_to_push = self.popper.next_objects!(queue.name, result.max)
          added = result.push(array_to_push, queue.name)
        end
        self.fill_count += added
      else
        ratio = 1.0 / self.popper.primary.length
        max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio)
        if self.strategy == :drain_to_limit
          self.popper.primary.each do |queue|
            puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}]" if Qfill::VERBOSE
            array_to_push = self.popper.next_objects!(queue.name, max_from_list)
            added = result.push(array_to_push, queue.name)
          end
          self.fill_count += added
        elsif self.strategy == :sample
          while !is_full? && !result.is_full? && !self.popper.totally_empty? && (origin_list = self.popper.current_list)
            puts "[fill_up_to_ratio!]#{self}" if Qfill::VERBOSE
            array_to_push = self.popper.next_objects!(origin_list.name, max_from_list)
            added = result.push(array_to_push, origin_list.name)
            self.fill_count += added
            self.popper.set_next_as_current!
          end
        end
      end
    end

    def is_full?
      self.fill_count >= self.all_list_max
    end

    def to_s
      "[#{self.strategy}][Max:#{self.result.max}][Primary #:#{self.popper.count_primary_elements}][Current Popper #{self.popper.current_list.name} #:#{self.popper.count_current_elements}]"
    end
  end
end
