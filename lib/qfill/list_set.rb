#popper = Qfill::ListSet.new(
#  Qfill::List.new( :name => "High List",
#                       :elements => [Thing1, Thing3],
#                       :filter => filter1 ) )
module Qfill
  class ListSet

    attr_accessor :queues, :current_index

    def initialize(*args)
      raise ArgumentError, "Missing required arguments for #{self.class}.new(queues)" unless args.length > 0
      @queues = args
      @current_index = 0
    end

    def [](key)
      return self.queues.find { |queue| queue.name == key }
    end

    def reset!
      self.current_index = 0
    end

    def get_total_elements
      self.queues.inject(0) {|counter, queue| counter += queue.elements.length}
    end

  end
end
