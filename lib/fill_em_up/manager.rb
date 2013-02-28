#FillEmUp::Manager.new(
#  :all_queue_max => 40,
#  :popper => popper,
#  :pusher => pusher,
#)
module FillEmUp
  class Manager
    attr_accessor :all_queue_max, :popper, :pusher

    def initialize(hash = {})
      @all_queue_max = hash[:all_queue_max]
      @popper = hash[:popper]
      @pusher = hash[:pusher]
    end
  end
end
