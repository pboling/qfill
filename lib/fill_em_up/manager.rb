#FillEmUp::Manager.new(
#  :all_queue_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module FillEmUp
  class Manager
    attr_accessor :all_queue_max, :popper, :pusher

    def initialize(options = {})
      unless options[:popper] && options[:pusher]
        raise ArgumentError, "popper and pusher are required options for #{self.class}.new(options)"
      end
      @popper = options[:popper]
      @pusher = options[:pusher]
      @all_queue_max = options[:all_queue_max]
    end
  end
end
