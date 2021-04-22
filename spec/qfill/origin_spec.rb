# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Origin do
  describe '#new' do
    context 'with no arguments' do
      it 'raises ArgumentError' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end

    context 'with name' do
      before do
        @arguments = { name: 'High List' }
      end

      it 'does not raise any errors' do
        expect { described_class.new(@arguments) }.not_to raise_error
      end

      it 'instantiates with name' do
        expect(described_class.new(@arguments).name).to eq('High List')
      end
    end

    context 'with elements' do
      before do
        @arguments = {  name: 'High List',
                        elements: [1, 2] }
      end

      it 'instantiates with elements' do
        expect(described_class.new(@arguments).elements).to eq([1, 2])
      end
    end

    context 'with backfill' do
      before do
        @arguments = {  name: 'High List',
                        elements: [1, 2],
                        backfill: 'Medium List' }
      end

      it 'instantiates with elements' do
        expect(described_class.new(@arguments).backfill).to eq('Medium List')
      end
    end

    context 'with filter' do
      before do
        lambda = ->(object) { !object.nil? }
        @filter = Qfill::Filter.new(lambda)
        @arguments = {  name: 'High List',
                        elements: [1, 2],
                        backfill: 'Medium List',
                        filter: @filter }
      end

      it 'instantiates with processor' do
        expect(described_class.new(@arguments).filter).to be_a(Qfill::Filter)
        expect(described_class.new(@arguments).filter).to eq(@filter)
      end
    end
  end
end
