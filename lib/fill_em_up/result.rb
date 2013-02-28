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

    attr_accessor :name, :filter, :ratio, :queue_ratios

    def initialize(options = {})
      @name = options[:name]
      @filter = options[:filter]
      @ratio = options[:ratio]
      @queue_ratios = options[:queue_ratios]
    end

  end
end
