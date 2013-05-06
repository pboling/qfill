#Qfill::Manager.new(
#  :all_list_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module Qfill
  class Manager
    attr_accessor :all_list_max, :popper, :pusher, :fill_count, :strategy, :result

    STRATEGY_OPTIONS = [:drain_to_limit, :drain_to_empty, :sample]

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
      @fill_count = 0
      @strategy = options[:strategy] || :drain_to_limit # or :drain_to_empty or :sample
    end

    def fill!
      while !is_full? && !self.popper.primary_empty? && (self.result = self.pusher.current_list)
        if self.current_strategy == :drain_to_empty
          preferred_potential_ratio = 0
          preferred_potential = 0
          self.result.list_ratios.each do |list_name, list_ratio|
            poppy = self.result.preferred.select {|x| x == list_name}
            if poppy
              preferred_potential_ratio += list_ratio
              num = self.popper[list_name].elements.length
              preferred_potential += num
              self.result.max_tracker[list_name] = num
            end
          end
          self.result.preferred_potential = preferred_potential
          self.result.preferred_potential_ratio = preferred_potential_ratio
        end
        self.fill_to_ratio!
        self.pusher.set_next_as_current!
        self.result.elements.shuffle! if self.result.shuffle
      end
    end

    def fill_to_ratio!
      case self.current_strategy
        when :drain_to_empty then
          result.max = self.result.preferred_potential_ratio > 0 ? [(self.result.preferred_potential / self.result.preferred_potential_ratio), self.remaining_to_fill].min : self.remaining_to_fill
        when :drain_to_limit, :sample then
          result.max = Qfill::Result.get_limit_from_max_and_ratio(self.remaining_to_fill, result.ratio)
      end
      #result.max = Qfill::Result.get_limit_from_max_and_ratio(self.all_list_max, result.ratio)
      if !result.list_ratios.empty?
        self.fill_according_to_list_ratios!
      else
        self.fill_up_to_ratio!
      end
    end

    def remaining_to_fill
      self.all_list_max - self.fill_count
    end

    # Go through the queues this result should be filled from and push elements from them onto the current result list.
    def fill_according_to_list_ratios!
      added = 0
      tally = 0
      ratio_modifier = 1
      case self.current_strategy
        when :drain_to_empty then
          # Are there any elements in preferred queues that we should add?
          if self.result.preferred_potential > 0
            # Setup a ratio modifier for the non-preferred queues
            result.list_ratios.each do |list_name, list_ratio|
              max_from_list = self.result.max_tracker[list_name] || Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio)
              array_to_push = self.popper.next_objects!(list_name, max_from_list)
              self.popper.current_index = self.popper.index_of(list_name)
              added = result.push(array_to_push, list_name)
              puts "[fill_according_to_list_ratios!]#{self}[#{list_name}][added:#{added}]" if Qfill::VERBOSE
              tally += added
            end
            self.fill_count += tally
          end
        when :drain_to_limit
          result.list_ratios.each do |list_name, list_ratio|
            max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio)
            array_to_push = self.popper.next_objects!(list_name, max_from_list)
            self.popper.current_index = self.popper.index_of(list_name)
            added = result.push(array_to_push, list_name)
            puts "[fill_according_to_list_ratios!]#{self}[#{list_name}][added:#{added}]" if Qfill::VERBOSE
            tally += added
          end
          self.fill_count += tally
        when :sample then
          #puts "#{!is_full?} && #{result.fill_count} >= #{result.max} && #{!self.popper.totally_empty?} && #{(list_ratio_tuple = result.current_list_ratio)}"
          while !is_full? && !result.is_full? && !self.popper.totally_empty? && (list_ratio_tuple = result.current_list_ratio)
            max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, list_ratio_tuple[1])
            array_to_push = self.popper.next_objects!(list_ratio_tuple[0], max_from_list)
            added = result.push(array_to_push, list_ratio_tuple[0])
            self.fill_count += added
            puts "[fill_according_to_list_ratios!]#{self}[#{list_ratio_tuple[0]}][added:#{added}]" if Qfill::VERBOSE
            result.set_next_as_current!
          end
      end
    end

    # Go through the primary (non backfill) queues in the popper and push elements from them onto the current result list.
    def fill_up_to_ratio!
      added = 0
      tally = 0
      if self.current_strategy == :drain_to_empty
        self.popper.primary.each do |queue|
          array_to_push = self.popper.next_objects!(queue.name, result.max)
          added = result.push(array_to_push, queue.name)
          self.popper.current_index = self.popper.index_of(queue.name)
          puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}][added:#{added}]" if Qfill::VERBOSE
          tally += added
        end
        self.fill_count += added
      else
        ratio = 1.0 / self.popper.primary.length # 1 divided by the number of queues
        max_from_list = Qfill::Result.get_limit_from_max_and_ratio(result.max, ratio)
        if self.current_strategy == :drain_to_limit
          self.popper.primary.each do |queue|
            array_to_push = self.popper.next_objects!(queue.name, max_from_list)
            added = result.push(array_to_push, queue.name)
            self.popper.current_index = self.popper.index_of(queue.name)
            puts "[fill_up_to_ratio!]#{self}[Q:#{queue.name}][added:#{added}]" if Qfill::VERBOSE
            tally += added
          end
          self.fill_count += tally
        elsif self.current_strategy == :sample
          while !is_full? && !result.is_full? && !self.popper.totally_empty? && (origin_list = self.popper.current_list)
            array_to_push = self.popper.next_objects!(origin_list.name, max_from_list)
            added = result.push(array_to_push, origin_list.name)
            self.fill_count += added
            puts "[fill_up_to_ratio!]#{self}[Added:#{added}][Max List:#{max_from_list}][ratio:#{ratio}][added:#{added}]" if Qfill::VERBOSE
            self.popper.set_next_as_current!
          end
        end
      end
    end

    def current_strategy
      (result.strategy || self.strategy)
    end

    def is_full?
      self.fill_count >= self.all_list_max
    end

    def to_s
      "[#{self.current_strategy}][Result Max:#{result.max}][All Max:#{self.all_list_max}][Current Max:#{self.result.max}][Filled:#{self.fill_count}][Primary #:#{self.popper.count_primary_elements}]"
    end
  end
end
