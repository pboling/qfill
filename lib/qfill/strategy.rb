# frozen_string_literal: true

module Qfill
  # A Strategy defines how to process the elements in the queues
  module Strategy
  end
end

require 'qfill/strategy/base'
require 'qfill/strategy/drain_to_empty'
require 'qfill/strategy/drain_to_limit'
require 'qfill/strategy/sample'
