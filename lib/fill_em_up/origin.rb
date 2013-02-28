#FillEmUp::Origin.new( :name => "High Queue",
#                    :elements => [Thing1, Thing3],
#                    :backfill => "Medium Queue",
#                    :filter => filter1),
#  FillEmUp::Origin.new( :name => "Medium Queue",
#                        :elements => [Thing2, Thing6],
#                        :backfill => "Low Queue",
#                        :filter => filter2),
#  FillEmUp::Origin.new( :name => "Low Queue",
#                        :elements => [Thing4, Thing5],
#                        :backfill => nil,
#                        :filter => filter1),
module FillEmUp
  class Origin
    attr_accessor :name, :elements, :backfill, :filter

    def initialize(hash = {})
      raise ArgumentError, "Missing required option :name for FillEmUp::Origin.new()" unless hash[:name]
      @name = hash[:name]
      @elements = hash[:elements]
      @backfill = hash[:backfill]
      @filter = hash[:filter]
    end

  end
end
