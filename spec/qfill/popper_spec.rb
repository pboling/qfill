# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Popper do
  describe '#new' do
    context 'with no arguments' do
      it 'raises ArgumentError' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end

    context 'with arguments' do
      before do
        @filter = Qfill::Filter.new(->(object) { object.is_a?(Numeric) })
        @origin_queues = [
          Qfill::Origin.new(
            name: 'High List',
            elements: [1, 2, 3, 'c'],
            backfill: 'Medium List',
            filter: @filter
          ),
          Qfill::Origin.new(name: 'Medium List',
                            elements: ['e', 'f', 4, 5],
                            backfill: 'Low List',
                            filter: @filter),
          Qfill::Origin.new(name: 'Low List',
                            elements: [7, 8, 'd'],
                            backfill: nil,
                            filter: @filter)
        ]
      end

      it 'does not raise any errors' do
        expect { described_class.new(*@origin_queues) }.not_to raise_error
      end

      it 'instantiates with name' do
        popper = described_class.new(*@origin_queues)
        expect(popper.queues.first.name).to eq('High List')
        expect(popper.queues.last.name).to eq('Low List')
      end

      it 'instantiates with elements' do
        popper = described_class.new(*@origin_queues)
        expect(popper.queues.first.elements).to eq([1, 2, 3, 'c'])
        expect(popper.queues.last.elements).to eq([7, 8, 'd'])
      end
    end
  end
end
