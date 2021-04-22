# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Result do
  describe '#new' do
    context 'with no arguments' do
      it 'raises ArgumentError' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end

    context 'with name' do
      before do
        @arguments = { name: 'Best Results' }
      end

      it 'does not raise any errors' do
        expect { described_class.new(@arguments) }.not_to raise_error
      end

      it 'instantiates with name' do
        expect(described_class.new(@arguments).name).to eq('Best Results')
      end
    end

    context 'with ratio' do
      before do
        @arguments = {  name: 'Best Results',
                        ratio: 0.5 }
      end

      it 'instantiates with elements' do
        expect(described_class.new(@arguments).ratio).to eq(0.5)
      end
    end

    context 'with filter' do
      before do
        lambda = ->(object) { !object.nil? }
        @filter = Qfill::Filter.new(lambda)
        @arguments = {  name: 'Best Results',
                        ratio: 0.5,
                        filter: @filter }
      end

      it 'instantiates with filter' do
        expect(described_class.new(@arguments).filter).to be_a(Qfill::Filter)
        expect(described_class.new(@arguments).filter).to eq(@filter)
      end
    end

    context 'with list_ratios' do
      before do
        @arguments = {  name: 'Best Results',
                        ratio: 0.5,
                        list_ratios: {
                          'High Price' => 0.4,
                          'Medium Price' => 0.3,
                          'Low Price' => 0.3
                        } }
      end

      it 'instantiates with elements' do
        expect(described_class.new(@arguments).list_ratios['High Price']).to eq(0.4)
      end
    end
  end
end
