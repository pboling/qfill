#popper = FillEmUp::Popper.new(
#  FillEmUp::Origin.new( :name => "High Queue",
#                        :elements => [Thing1, Thing3],
#                        :backfill => "Medium Queue",
#                        :filter => filter1),
#  FillEmUp::Origin.new( :name => "Medium Queue",
#                        :elements => [Thing2, Thing6],
#                        :backfill => "Low Queue",
#                        :filter => filter2),
#  FillEmUp::Origin.new( :name => "Low Queue",
#                        :elements => [Thing4, Thing5],
#                        :backfill => nil,
#                        :filter => filter1),
#)
#
#popper = FillEmUp::Popper.from_hash(
#  { :name => "High Queue",
#    :elements => [Thing1, Thing3, Thing7, Thing8, Thing12, Thing15, Thing17],
#    :backfill => "Medium Queue",
#    :filter => filter1},
#  { :name => "Medium Queue",
#    :elements => [Thing2, Thing6, Thing11, Thing 16],
#    :backfill => "Low Queue",
#    :filter => filter2},
#  { :name => "Low Queue",
#    :elements => [Thing4, Thing5, Thing9, Thing10, Thing13, Thing14, Thing18, Thing19, Thing20],
#    :backfill => nil,
#    :filter => filter1},
#)
module FillEmUp
  class Popper < FillEmUp::QueueSet

    attr_accessor :queues

    def self.from_hashes(hashes = {})
      hashes.each do |hash|
        FillEmUp::Origin.new(hash)
      end
    end

  end
end
