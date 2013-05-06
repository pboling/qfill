# Qfill::Result.new(:name => "Best Results",
#                      :filter => filter3,
#                      :ratio => 0.5,
#                      :list_ratios => {
#                        "High List" => 0.4,
#                        "Medium List" => 0.2,
#                        "Low List" => 0.4 } )
module Qfill
  class Result < Qfill::List
    attr_accessor :ratio, :list_ratios, :fill_tracker, :fill_count, :validate, :filter, :current_list_ratio_index, :max

    def self.get_limit_from_max_and_ratio(all_list_max, ratio)
      limit = (all_list_max * ratio).round(0)
      # If we rounded down to zero we have to keep at least one.
      # This is because with small origin sets all ratios might round down to 0.
      if limit == 0
        limit += 1
      end
      limit
    end

    def initialize(options = {})
      super(options)
      @list_ratios = options[:list_ratios] || {}
      with_ratio = self.list_ratio_as_array.map {|tuple| tuple[1]}.compact
      ratio_leftover = (1 - with_ratio.inject(0, :+))
      if ratio_leftover < 0
        raise ArgumentError, "#{self.class}: invalid list_ratios for queue '#{self.name}'. List Ratios (#{with_ratio.join(' + ')}) must not total more than 1"
      end
      @ratio = options[:ratio] || 1
      @max = 0
      @fill_tracker = {}
      @fill_count = 0
      @current_list_ratio_index = 0 # Used by :sample strategy
      @validate = self.use_validation?
    end

    def list_ratio_full?(list_name, max_from_list)
      self.fill_tracker[list_name] >= max_from_list
    end

    def push(objects, list_name)
      self.validate!(list_name)
      added = 0
      objects.each do |object|
        if self.allow?(object, list_name)
          self.bump_fill_tracker!(list_name)
          self.add!(object)
          added += 1
          #self.print(list_name)
        end
      end
      return added
    end

    def print(list_name)
      puts "Added to #{list_name}.\nResult List #{self.name} now has #{self.elements.length} total objects.\nSources:\n #{self.fill_tracker.inspect} "
    end

    def add!(object)
      self.elements << object
    end

    def allow?(object, list_name)
      !self.filter.respond_to?(:call) ||
        # If there is a filter, then it must return true to proceed
        self.filter.run(object, list_name)
    end

    def bump_fill_tracker!(list_name)
      self.fill_tracker[list_name] ||= 0
      self.fill_tracker[list_name] += 1
      self.fill_count += 1
    end

    # Does the queue being pushed into match one of the list_ratios
    def valid?(list_name)
      self.list_ratios.has_key?(list_name)
    end

    def validate!(list_name)
      raise ArgumentError, "#{self.class}: #{list_name} is an invalid list_name.  Valid list_names are: #{self.list_ratios.keys}" if self.validate && !self.valid?(list_name)
    end

    def use_validation?
      !self.list_ratios.empty?
    end

    def list_ratio_as_array
      # [["high",0.4],["medium",0.4],["low",0.2]]
      @list_ratio_as_array ||= self.list_ratios.to_a
    end

    def current_list_ratio
      self.list_ratio_as_array[self.current_list_ratio_index]
    end

    def set_next_as_current!
      next_index = self.current_list_ratio_index + 1
      if (next_index) == self.list_ratio_as_array.length
        # If we have iterated through all the list_ratios, then we reset
        self.reset!
      else
        self.current_list_ratio_index = next_index
      end
    end

    def reset!
      self.current_list_ratio_index = 0
    end

    def is_full?
      self.fill_count >= self.max
    end

    def to_s
      "Qfill::Result: ratio: #{self.ratio}, list_ratios: #{self.list_ratios}, fill_tracker: #{self.fill_tracker}, fill_count: #{self.fill_count}, filter: #{!!self.filter ? 'Yes' : 'No'}, current_list_ratio_index: #{self.current_list_ratio_index}, max: #{self.max}"
    end
  end
end
