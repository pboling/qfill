# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Filter do
  describe '#new' do
    context 'with processor' do
      before do
        @lambda = ->(object) { !object.nil? }
      end

      it 'instantiates with processor' do
        expect(described_class.new(@lambda)).to be_a(described_class)
      end
    end

    context 'with processor and arguments' do
      before do
        @lambda = ->(object, first, second) { !object.nil? && first == first && second == 'second' }
        @arguments = %w[first second]
      end

      it 'instantiates with processor' do
        expect(described_class.new(@lambda, *@arguments)).to be_a(described_class)
      end
    end
  end

  describe '#run' do
    before do
      @lambda = ->(object, first, second) { !object.nil? && first == first && second == 'second' }
      @arguments = %w[first second]
      @filter = described_class.new(@lambda, *@arguments)
    end

    it 'returns the correct result' do
      expect(@filter.run('not nil')).to eq(true)
    end

    context 'with extra arguments' do
      before do
        @lambda = lambda { |object, _special_arg1, special_arg2, first, second, third|
          !object.nil? && first == first && second == 'second' && special_arg1 = 'this' && special_arg2 == 'thing' && third == 'third'
        }
        @arguments = %w[first second third]
        @filter = described_class.new(@lambda, *@arguments)
      end

      it 'properlies use arity' do
        expect(@filter.run('not nil', 'this', 'thing')).to eq(true)
      end
    end
  end
end
