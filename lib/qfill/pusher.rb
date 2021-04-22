# frozen_string_literal: true

# A Qfill::Pusher (which inherits from Qfill::ListSet) is a set of result data
#   which contribute to the definition of the result set created by the Qfill::Manager.
# Qfill::Pusher is made up of an array (called queues) of Qfill::Result objects (which inherit from Qfill::List).
#
# pusher = Qfill::Pusher.new(
#  Qfill::Result.new( :name => "Best Results",
#                        :filter => filter3,
#                        :ratio => 0.5,
#                        :list_ratios => {
#                          "High List" => 0.4,
#                          "Medium List" => 0.2,
#                          "Low List" => 0.4
#                        }
#  ),
#  Qfill::Result.new( :name => "More Results",
#                        :ratio => 0.5,
#                        :list_ratios => {
#                          "High List" => 0.2,
#                          "Medium List" => 0.4,
#                          "Low List" => 0.4
#                        }
#  )
# )
#
# pusher = Qfill::Pusher.from_array_of_hashes([
#  { :name => "First Result",
#    :ratio => 0.125,
#    :filter => filter3,
#    :list_ratios => {
#      "High List" => 0.4,
#      "Medium List" => 0.2,
#      "Low List" => 0.4
#    }
#  },
#  { :name => "Second Result",
#    :ratio => 0.25 },
#  { :name => "Third Result",
#    :ratio => 0.125 },
#  { :name => "Fourth Result",
#    :ratio => 0.50 },
# ])
#
# Pusher is made up of an array (called queues) of Result objects.
module Qfill
  class Pusher < Qfill::ListSet
    def initialize(*args)
      super(*args)
      with_ratio = queues.map(&:ratio).compact
      ratio_to_split = (1 - with_ratio.sum)
      # if ratio_to_split < 0
      #  raise ArgumentError, "#{self.class}: mismatched ratios for queues #{with_ratio.join(' + ')} must not total more than 1"
      # end
      num_without_ratio = queues.length - with_ratio.length
      if num_without_ratio.positive? && ratio_to_split <= 1
        equal_portion = ratio_to_split / num_without_ratio
        queues.each do |queue|
          next unless queue.ratio.nil?

          queue.tap do |q|
            q.ratio = equal_portion
          end
        end
      end
    end

    def current_list
      queues[current_index]
    end

    def set_next_as_current!
      next_index = current_index + 1
      if (next_index) == queues.length
        # If we have iterated through all the queues, then we reset
        reset!
      else
        self.current_index = next_index
      end
    end

    def self.from_array_of_hashes(array_of_hashes = [])
      args = array_of_hashes.map do |hash|
        Qfill::Result.new(hash)
      end
      Qfill::Pusher.new(*args)
    end

    def more_to_fill?
      !queues.reject(&:is_full?).empty?
    end

    def next_to_fill
      queues.reject(&:is_full?).first
    end

    def each
      # NOTE on magic: http://blog.arkency.com/2014/01/ruby-to-enum-for-enumerator/
      return enum_for(:each) unless block_given? # Sparkling magic!

      queues.each do |result|
        yield result
      end
    end
  end
end
