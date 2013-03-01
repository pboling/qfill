#FillEmUp::Origin.new(:name => "High Queue",
#                     :elements => [Thing1, Thing3],
#                     :backfill => "Medium Queue",
#                     :filter => filter1),
module FillEmUp
  class Origin < FillEmUp::Queue
    attr_accessor :backfill

    def initialize(options = {})
      super(options)
      @backfill = options[:backfill]
    end

  end
end
