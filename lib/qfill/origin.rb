#Qfill::Origin.new(:name => "High List",
#                     :elements => [Thing1, Thing3],
#                     :backfill => "Medium List",
#                     :filter => filter1),
module Qfill
  class Origin < Qfill::List
    attr_accessor :backfill

    def initialize(options = {})
      super(options)
      @backfill = options[:backfill]
    end

    def has_backfill?
      !!self.backfill
    end

  end
end
