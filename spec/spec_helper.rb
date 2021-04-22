# frozen_string_literal: true

require 'qfill'

require 'byebug' if RUBY_ENGINE == 'ruby'
require 'support/helper'
require 'support/random_object'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include Support::Helper

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
  config.before do
    stub_const('Qfill::VERBOSE', false)
  end
end
