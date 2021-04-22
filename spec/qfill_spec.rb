# frozen_string_literal: true

require 'spec_helper'
describe Qfill do
  it 'has string version' do
    expect(Qfill::VERSION).to be_a(String)
  end

  it 'has major, minor & patch version levels' do
    expect(Qfill::VERSION).to match(/\d+\.\d+\.\d+/)
  end
end
