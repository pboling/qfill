# frozen_string_literal: true

# This is the base queue class for Origin queues and Result queues.
#
# Qfill::List.new(:name => "High List",
#                    :elements => [Thing1, Thing3],
#                    :filter => filter1),
module Qfill
  class List
    attr_accessor :name, :elements, :filter

    def initialize(options = {})
      raise ArgumentError, "Missing required option :name for #{self.class}.new()" unless options && options[:name]

      @name = options[:name]
      @elements = options[:elements] || []
      @filter = options[:filter]
    end
  end
end
