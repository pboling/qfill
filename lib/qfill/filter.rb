#filter1 = Qfill::Filter.new( -> (object, stuff, stank) { object.is_awesome_enough_to_be_in_results?(stuff, stank) }, stuff, stank)
#filter2 = Qfill::Filter.new( -> (object, rank, bank) { object.is_awesome_enough_to_be_in_results?(rank, bank) }, rank, bank)
#
# Filters are destructive. If an item is filtered from a Result list it is lost, since it has already been popped off the origin list, and won't be coming back
module Qfill
  class Filter
    attr_accessor :processor, :processor_arguments

    def initialize(proc, *params)
      @processor = proc
      @processor_arguments = params
    end

    def run(*args)
      self.processor.call(*args, *self.processor_arguments)
    end
  end
end
