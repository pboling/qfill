# frozen_string_literal: true

# A Qfill::Popper (which inherits from Qfill::ListSet) is a set of source data
#   which will be added to the Qfill::Pusher, by the Qfill::Manager, when generating the result data.
# Qfill::Popper is made up of an array (called queues) of Qfill::Origin objects (which inherit from Qfill::List).
#
# popper = Qfill::Popper.new(
#  Qfill::Origin.new( :name => "High List",
#                        :elements => [Thing1, Thing3],
#                        :backfill => "Medium List",
#                        :filter => filter1),
#  Qfill::Origin.new( :name => "Medium List",
#                        :elements => [Thing2, Thing6],
#                        :backfill => "Low List",
#                        :filter => filter2),
#  Qfill::Origin.new( :name => "Low List",
#                        :elements => [Thing4, Thing5],
#                        :backfill => nil,
#                        :filter => filter1),
# )
#
# popper = Qfill::Popper.from_array_of_hashes([
#  { :name => "High List",
#    :elements => [Thing1, Thing3, Thing7, Thing8, Thing12, Thing15, Thing17],
#    :backfill => "Medium List",
#    :filter => filter1},
#  { :name => "Medium List",
#    :elements => [Thing2, Thing6, Thing11, Thing 16],
#    :backfill => "Low List",
#    :filter => filter2},
#  { :name => "Low List",
#    :elements => [Thing4, Thing5, Thing9, Thing10, Thing13, Thing14, Thing18, Thing19, Thing20],
#    :backfill => nil,
#    :filter => filter1},
# ])
#
module Qfill
  class Popper < Qfill::ListSet
    attr_accessor :total_elements

    class << self
      def from_array_of_hashes(array_of_hashes = [])
        args = array_of_hashes.map do |hash|
          Qfill::Origin.new(hash)
        end
        Qfill::Popper.new(*args)
      end
    end

    def initialize(*args)
      super(*args)
      @total_elements = count_all_elements
    end

    def primary
      @primary ||= queues.reject { |x| x.backfill == true }
    end

    def current_list
      primary[current_index]
    end

    def set_next_as_current!
      next_index = current_index + 1
      if (next_index) >= primary.length
        # If we have iterated through all the queues, then we reset
        reset!
      else
        self.current_index = next_index
      end
    end

    def next_objects!(list_name, n = 1)
      origin_list = self[list_name]
      if origin_list.elements.length >= n
        origin_list.elements.pop(n)
      else
        result = origin_list.elements.pop(n)
        while result.length < n && origin_list.has_backfill?
          secondary_list = self[origin_list.backfill]
          remaining = n - result.length
          result += secondary_list.elements.pop(remaining)
          origin_list = secondary_list
        end
        result
      end
    end

    def primary_empty?
      count_primary_elements.zero?
    end

    def totally_empty?
      count_all_elements.zero?
    end

    def count_primary_elements
      primary.inject(0) { |counter, queue| counter += queue.elements.length }
    end
  end
end
