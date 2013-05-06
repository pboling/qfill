#popper = Qfill::Popper.new(
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
#)
#
#popper = Qfill::Popper.from_array_of_hashes([
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
#])
#
# Popper is made up of an array (called queues) of Origin objects.
module Qfill
  class Popper < Qfill::ListSet

    attr_accessor :total_elements

    def initialize(*args)
      super(*args)
      @total_elements = get_total_elements
    end

    def primary
      @primary ||= self.queues.select {|x| x.backfill != true}
    end

    def current_list
      self.primary[self.current_index]
    end

    def set_next_as_current!
      next_index = self.current_index + 1
      if (next_index) >= self.primary.length
        # If we have iterated through all the queues, then we reset
        self.reset!
      else
        self.current_index = next_index
      end
    end

    def next_objects!(list_name, n = 1)
      origin_list = self[list_name]
      if origin_list.elements.length >= n
        return origin_list.elements.pop(n)
      else
        result = origin_list.elements.pop(n)
        while result.length < n && origin_list.has_backfill?
          secondary_list = self[origin_list.backfill]
          remaining = n - result.length
          result += secondary_list.elements.pop(remaining)
          origin_list = secondary_list
        end
        return result
      end
    end

    def self.from_array_of_hashes(array_of_hashes = [])
      args = array_of_hashes.map do |hash|
        Qfill::Origin.new(hash)
      end
      Qfill::Popper.new(*args)
    end

    def primary_empty?
      self.count_primary_elements == 0
    end

    def totally_empty?
      self.get_total_elements == 0
    end

    def count_primary_elements
      self.primary.inject(0) {|counter, queue| counter += queue.elements.length}
    end

  end
end
