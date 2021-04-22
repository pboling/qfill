# frozen_string_literal: true

class RandomObject
  attr_accessor :rating, :queue

  def initialize(options = {})
    @rating = options[:rating] || RandomObject.random_rating
    @queue = RandomObject.list_designation(rating)
  end

  def self.random_rating
    rand(101) # 0 - 100
  end

  def self.list_designation(rating)
    if rating == 0
      'none'
    elsif rating < 34
      'low'
    elsif rating < 67
      'medium'
    else
      'high'
    end
  end

  def to_s
    "RO:#{rating}:#{queue}"
  end
end
