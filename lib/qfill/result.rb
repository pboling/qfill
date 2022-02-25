# frozen_string_literal: true

# :preferred is used for :drain_to_empty
# :ratio is used for the other strategies
# Qfill::Result.new(:name => "Best Results",
#                      :filter => filter3,
#                      :ratio => 0.5,
#                      :list_ratios => {
#                        "High List" => 0.4,
#                        "Medium List" => 0.2,
#                        "Low List" => 0.4 },
#                      :preferred => ["High List", "Medium List"]
# )
module Qfill
  class Result < Qfill::List
    attr_accessor :ratio,
                  :list_ratios,
                  :fill_tracker,
                  :total_count,
                  :current_count,
                  :validate,
                  :current_list_ratio_index,
                  :max,
                  :shuffle,
                  :preferred,
                  :preferred_potential,
                  :preferred_potential_ratio,
                  :max_tracker

    def self.get_limit_from_max_and_ratio(all_list_max, ratio, remain = nil)
      return 1 if remain == 1

      limit = (all_list_max * ratio).round(0)
      # If we rounded down to zero we have to keep at least one.
      # This is because with small origin sets all ratios might round down to 0.
      limit += 1 if limit.zero?
      remain ? [limit, remain].min : limit
    end

    def initialize(options = {})
      super(options)
      @list_ratios = options[:list_ratios] || {}
      with_ratio = list_ratio_as_array.map { |tuple| tuple[1] }.compact
      ratio_leftover = (1 - with_ratio.sum)
      if ratio_leftover.negative?
        raise ArgumentError,
              "#{self.class}: invalid list_ratios for queue '#{name}'. List Ratios (#{with_ratio.join(' + ')}) must not total more than 1"
      end

      @ratio = options[:ratio] || 1
      @max = 0
      @preferred = options[:preferred] # Used by :drain_to_empty and :drain_to_limit
      @preferred_potential = 0
      @preferred_potential_ratio = 0
      @fill_tracker = {}
      @max_tracker = {}
      # Doesn't reset to 0 on reset!
      @total_count = 0
      # Does reset to 0 on reset!
      @current_count = 0
      @shuffle = options[:shuffle] || false
      @current_list_ratio_index = 0 # Used by :sample strategy
      @validate = use_validation?
    end

    def list_ratio_full?(list_name, max_from_list)
      fill_tracker[list_name] >= max_from_list
    end

    def push(objects, list_name)
      validate!(list_name)
      added = 0
      fill_tracker[list_name] ||= 0
      objects.each do |object|
        # The objects have already been popped.
        # The only valid reason to not push an object at this point is if !allow?.
        # break if is_full?

        next unless allow?(object, list_name)

        bump_fill_tracker!(list_name)
        add!(object)
        added += 1
        # self.print(list_name)
      end
      added
    end

    def print(list_name)
      puts "Added to #{list_name}.\nResult List #{name} now has #{elements.length} total objects.\nSources:\n #{fill_tracker.inspect} "
    end

    def add!(object)
      elements << object
    end

    def allow?(object, list_name)
      !filter.respond_to?(:call) ||
        # If there is a filter, then it must return true to proceed
        filter.run(object, list_name)
    end

    def bump_fill_tracker!(list_name)
      fill_tracker[list_name] += 1
      self.total_count += 1
      self.current_count += 1
    end

    # Does the queue being pushed into match one of the list_ratios
    def valid?(list_name)
      list_ratios.key?(list_name)
    end

    def validate!(list_name)
      if validate && !valid?(list_name)
        raise ArgumentError,
              "#{self.class}: #{list_name} is an invalid list_name.  Valid list_names are: #{list_ratios.keys}"
      end
    end

    def use_validation?
      !list_ratios.empty?
    end

    def list_ratio_as_array
      # [["high",0.4],["medium",0.4],["low",0.2]]
      @list_ratio_as_array ||= list_ratios.to_a
    end

    def current_list_ratio
      list_ratio_as_array[current_list_ratio_index]
    end

    def set_next_as_current!
      next_index = current_list_ratio_index + 1
      if (next_index) == list_ratio_as_array.length
        # If we have iterated through all the list_ratios, then we reset
        reset!
      else
        self.current_list_ratio_index = next_index
      end
    end

    def reset!
      self.current_list_ratio_index = 0
      self.current_count = 0
    end

    def is_full?
      self.total_count >= max
    end

    def to_s
      "Qfill::Result: ratio: #{ratio}, list_ratios: #{list_ratios}, fill_tracker: #{fill_tracker}, total_count: #{self.total_count}, current_count: #{self.current_count}, filter: #{!!filter ? 'Yes' : 'No'}, current_list_ratio_index: #{current_list_ratio_index}, max: #{max}"
    end
  end
end
