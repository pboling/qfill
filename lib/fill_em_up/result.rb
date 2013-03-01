# FillEmUp::Result.new( :name => "Best Results",
#                      :filter => filter3,
#                      :ratio => 0.5,
#                      :queue_ratios => {
#                        "High Queue" => 0.4,
#                        "Medium Queue" => 0.2,
#                        "Low Queue" => 0.4
#                      }
# )
# FillEmUp::Result.new( :name => "More Results",
#                        :ratio => 0.5,
#                        :queue_ratios => {
#                          "High Queue" => 0.2,
#                          "Medium Queue" => 0.4,
#                          "Low Queue" => 0.4
#                        }
# )
module FillEmUp
  class Result

    attr_accessor :name, :ratio, :filter, :queue_ratios

    def initialize(options = {})
      raise ArgumentError, "Missing required option :name for FillEmUp::Origin.new()" unless options[:name]
      @name = options[:name]
      @ratio = options[:ratio]
      @filter = options[:filter]
      @queue_ratios = options[:queue_ratios]
    end

  end
end
