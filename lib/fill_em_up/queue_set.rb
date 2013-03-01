#popper = FillEmUp::QueueSet.new(
#  FillEmUp::Queue.new( :name => "High Queue",
#                       :elements => [Thing1, Thing3],
#                       :filter => filter1 ) )
module FillEmUp
  class QueueSet

    attr_accessor :queues

    def initialize(*args)
      raise ArgumentError, "Missing required arguments for #{self.class}.new(queues)" unless args.length > 0
      @queues = args
    end

  end
end
