#filter1 = FillEmUp::Filter.new( -> (object, stuff, stank) { object.is_awesome_enough_to_be_in_results?(stuff, stank) }, stuff, stank)
#filter2 = FillEmUp::Filter.new( -> (object, rank, bank) { object.is_awesome_enough_to_be_in_results?(rank, bank) }, rank, bank)
module FillEmUp
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
