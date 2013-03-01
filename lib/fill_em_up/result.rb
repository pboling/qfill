# FillEmUp::Result.new(:name => "Best Results",
#                      :filter => filter3,
#                      :ratio => 0.5,
#                      :queue_ratios => {
#                        "High Queue" => 0.4,
#                        "Medium Queue" => 0.2,
#                        "Low Queue" => 0.4 } )
module FillEmUp
  class Result < FillEmUp::Queue
    attr_accessor :ratio, :queue_ratios

    def initialize(options = {})
      super(options)
      @ratio = options[:ratio]
      @queue_ratios = options[:queue_ratios]
    end

  end
end
