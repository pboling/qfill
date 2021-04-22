# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Pusher do
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
          Qfill::Result.new({ name: 'Top Results',
                              ratio: 0.4,
                              list_ratios: {
                                'High Price' => 0.2,
                                'Medium Price' => 0.3,
                                'Low Price' => 0.5
                              } }),
          Qfill::Result.new({ name: 'Page Results',
                              ratio: 0.6,
                              list_ratios: {
                                'High Price' => 0.5,
                                'Medium Price' => 0.3,
                                'Low Price' => 0.2
                              } })
        ]
      end

      it 'does not raise any errors' do
        expect { described_class.new(*@origin_queues) }.not_to raise_error
      end

      it 'instantiates with name' do
        popper = described_class.new(*@origin_queues)
        expect(popper.queues.first.name).to eq('Top Results')
        expect(popper.queues.last.name).to eq('Page Results')
      end
    end
  end
end
