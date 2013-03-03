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
#pusher = FillEmUp::Pusher.from_array_of_hashes([
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
#])
module FillEmUp
  class Pusher < FillEmUp::QueueSet

    attr_accessor :queues

    def initialize(*args)
      super(*args)
      with_ratio = self.queues.map {|x| x.ratio}.compact
      ratio_to_split = with_ratio.inject(0, :+)
      num_without_ratio = self.queues.length - with_ratio.length
      if num_without_ratio > 0 && ratio_to_split < 1
        equal_portion = ratio_to_split / num_without_ratio
        self.queues.each do |queue|
          if queue.ratio.nil?
            queue.tap do |q|
              q.ratio = equal_portion
            end
          end
        end
      end
    end

    def self.from_array_of_hashes(array_of_hashes = [])
      args = array_of_hashes.map do |hash|
        FillEmUp::Result.new(hash)
      end
      FillEmUp::Pusher.new(*args)
    end

  end
end
