#FillEmUp::Manager.new(
#  :all_queue_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module FillEmUp
  class Manager
    attr_accessor :all_queue_max, :popper, :pusher

    def initialize(options = {})
      @all_queue_max = options[:all_queue_max]
      @popper = options[:popper]
      @pusher = options[:pusher]
    end
  end
end
