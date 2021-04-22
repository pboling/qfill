# frozen_string_literal: true

require 'qfill/version'
require 'qfill/filter'
require 'qfill/list'
require 'qfill/list_set'
require 'qfill/origin'
require 'qfill/popper'
require 'qfill/pusher'
require 'qfill/manager'
require 'qfill/result'
require 'qfill/strategy'

module Qfill
  VERBOSE = ENV['QFILL_VERBOSE'] == 'true'
end
