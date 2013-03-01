#pusher = FillEmUp::Pusher.new(
#  FillEmUp::Result.new( :name => "Best Results",
#                        :filter => filter3,
#                        :ratio => 0.5,
#                        :queue_ratios => {
#                          "High Queue" => 0.4,
#                          "Medium Queue" => 0.2,
#                          "Low Queue" => 0.4
#                        }
#  ),
#  FillEmUp::Result.new( :name => "More Results",
#                        :ratio => 0.5,
#                        :queue_ratios => {
#                          "High Queue" => 0.2,
#                          "Medium Queue" => 0.4,
#                          "Low Queue" => 0.4
#                        }
#  )
#)
#
#pusher = FillEmUp::Pusher.from_hash(
#  { :name => "First Result",
#    :ratio => 0.125,
#    :filter => filter3,
#    :ratios => {
#      "High Queue" => 0.4,
#      "Medium Queue" => 0.2,
#      "Low Queue" => 0.4
#    }
#  },
#  { :name => "Second Result",
#    :ratio => 0.25 },
#  { :name => "Third Result",
#    :ratio => 0.125 },
#  { :name => "Fourth Result",
#    :ratio => 0.50 },
#)
module FillEmUp
  class Pusher < FillEmUp::QueueSet

    attr_accessor :queues

    def self.from_hashes(hashes = {})
      hashes.each do |hash|
        FillEmUp::Result.new(hash)
      end
    end

  end
end
