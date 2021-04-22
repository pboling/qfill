# frozen_string_literal: true

require 'spec_helper'
describe Qfill::Manager do
  let(:manager) { described_class.new(arguments) }

  describe '#new' do
    context 'with no arguments' do
      it 'raises ArgumentError' do
        expect { described_class.new }.to raise_error(ArgumentError)
      end
    end

    context 'with only popper' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          [{ name: 'High List',
             elements: [1, 2, 3] }]
        )
      end

      it 'raises ArgumentError' do
        expect { described_class.new(popper: popper) }.to raise_error(ArgumentError)
      end
    end

    context 'with only pusher' do
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'Some Result',
             ratio: 0.25 }]
        )
      end

      it 'raises ArgumentError' do
        expect { described_class.new(pusher: pusher) }.to raise_error(ArgumentError)
      end
    end

    context 'with popper and pusher' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          [{ name: 'High List',
             elements: [1, 2, 3] }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'Some Result',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper
        }
      end

      it 'does not raise any errors' do
        expect { described_class.new(arguments) }.not_to raise_error
      end

      it 'instantiates with pusher' do
        expect(described_class.new(arguments).pusher).to eq(pusher)
      end

      it 'instantiates with popper' do
        expect(described_class.new(arguments).popper).to eq(popper)
      end
    end

    context 'with popper and pusher and all_list_max smaller than # total elements' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          [{ name: 'High List',
             elements: [1, 2, 3] }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'Some Result',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 2
        }
      end

      it 'does not raise any errors' do
        expect { described_class.new(arguments) }.not_to raise_error
      end

      it 'instantiates with pusher' do
        expect(described_class.new(arguments).pusher).to eq(pusher)
      end

      it 'instantiates with popper' do
        expect(described_class.new(arguments).popper).to eq(popper)
      end

      it 'retains specified all_list_max' do
        expect(described_class.new(arguments).all_list_max).to eq(2)
      end
    end

    context 'all_list_max greater than # total elements' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          [{ name: 'High List',
             elements: [1, 2, 3] }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'Some Result',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 666
        }
      end

      it 'reduces all_list_max to number of elements' do
        expect(described_class.new(arguments).all_list_max).to eq(3)
      end
    end
  end

  context 'when strategy => :sample' do
    context 'when backfill => false' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: %w[h1 h2 h3 h4 h5 h6 h7 h8 h9],
             backfill: 'medium' },
           { name: 'medium',
             elements: %w[m1 m2 m3 m4 m5 m6 m7 m8 m9],
             backfill: 'none' },
           { name: 'low',
             elements: %w[l1 l2 l3 l4 l5 l6 l7 l8 l9],
             backfill: false },
           { name: 'none',
             elements: %w[n1 n2 n3 n4 n5 n6 n7 n8 n9],
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             ratio: 0.25 },
           { name: 'second',
             ratio: 0.50 },
           { name: 'third',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 40,
          strategy: :sample
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
        context 'before fill!' do
          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(36)
          end

          it 'calculates the correct popper primary elements' do
            manager.popper.count_primary_elements == 36
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(0)
          end
        end

        context 'after fill!' do
          before do
            manager.fill!
          end

          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(0)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(0)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(36)
          end
        end
      end
    end

    context 'when backfill => true' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: %w[h1 h2 h3 h4 h5 h6 h7 h8 h9],
             backfill: 'medium' },
           { name: 'medium',
             elements: %w[m1 m2 m3 m4 m5 m6 m7 m8 m9],
             backfill: 'none' },
           { name: 'low',
             elements: %w[l1 l2 l3 l4 l5 l6 l7 l8 l9],
             backfill: true },
           { name: 'none',
             elements: %w[n1 n2 n3 n4 n5 n6 n7 n8 n9],
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             ratio: 0.25 },
           { name: 'second',
             ratio: 0.50 },
           { name: 'third',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 28,
          strategy: :sample
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
        context 'before fill!' do
          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(36)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(27)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(0)
          end
        end

        context 'after fill!' do
          before do
            manager.fill!
          end

          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(8)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(0)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(28)
          end
        end
      end
    end
  end

  context 'when strategy => :drain_to_limit' do
    context 'when backfill => false' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: %w[h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12],
             backfill: 'medium' },
           { name: 'medium',
             elements: %w[m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12],
             backfill: 'none' },
           { name: 'low',
             elements: %w[l1 l2 l3 l4 l5 l6 l7 l8 l9 l10 l11 l12],
             backfill: false },
           { name: 'none',
             elements: %w[n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 n12],
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             ratio: 0.25 },
           { name: 'second',
             ratio: 0.50 },
           { name: 'third',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 40,
          strategy: :drain_to_limit
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
        context 'before fill!' do
          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(48)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(48)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(0)
          end
        end

        context 'after fill!' do
          before do
            manager.fill!
          end

          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(8) # With drain_to_limit the results do not exactly match the requested ratios.
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(8)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(40)
          end
        end
      end
    end

    context 'when backfill => true' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of hte experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: %w[h1 h2 h3 h4 h5 h6 h7 h8 h9],
             backfill: 'medium' },
           { name: 'medium',
             elements: %w[m1 m2 m3 m4 m5 m6 m7 m8 m9],
             backfill: 'none' },
           { name: 'low',
             elements: %w[l1 l2 l3 l4 l5 l6 l7 l8 l9],
             backfill: true },
           { name: 'none',
             elements: %w[n1 n2 n3 n4 n5 n6 n7 n8 n9],
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             ratio: 0.25 },
           { name: 'second',
             ratio: 0.50 },
           { name: 'third',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 40,
          strategy: :drain_to_limit
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
        context 'before fill!' do
          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(36)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(27)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(0)
          end
        end

        context 'after fill!' do
          before do
            manager.fill!
          end

          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(7) # With drain_to_limit the results do not exactly match the requested ratios.
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(0)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(29)
          end
        end
      end
    end
  end

  context 'when strategy => :drain_to_empty' do
    context 'when backfill => false' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, higspec/qfill/manager_spec.rb:386h, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of the experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: %w[h1 h2 h3 h4 h5 h6 h7 h8 h9],
             backfill: 'medium' },
           { name: 'medium',
             elements: %w[m1 m2 m3 m4 m5 m6 m7 m8 m9],
             backfill: 'none' },
           { name: 'low',
             elements: %w[l1 l2 l3 l4 l5 l6 l7 l8 l9],
             backfill: false },
           { name: 'none',
             elements: %w[n1 n2 n3 n4 n5 n6 n7 n8 n9],
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             preferred: %w[high none] },
           { name: 'second',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.4,
               'none' => 0.1
             },
             preferred: %w[high medium] },
           { name: 'third' }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 40,
          strategy: :drain_to_empty
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
      end

      context 'before fill!' do
        it 'calculates the correct popper total elements' do
          expect(manager.popper.count_all_elements).to eq(36)
        end

        it 'calculates the correct popper primary elements' do
          expect(manager.popper.count_primary_elements).to eq(36)
        end

        it 'calculates the correct pusher total elements' do
          expect(manager.pusher.count_all_elements).to eq(0)
        end
      end

      context 'after fill!' do
        before do
          manager.fill!
        end

        it 'calculates the correct popper total elements' do
          expect(manager.popper.count_all_elements).to eq(0) # With drain_to_limit the results do not exactly match the requested ratios.
        end

        it 'calculates the correct popper primary elements' do
          expect(manager.popper.count_primary_elements).to eq(0)
        end

        it 'calculates the correct pusher total elements' do
          expect(manager.pusher.count_all_elements).to eq(36)
        end
      end
    end

    context 'when backfill => true' do
      let(:popper) do
        Qfill::Popper.from_array_of_hashes(
          # We will create 4 queues, high, medium, low, and none.
          # These might be queue of things that have ratings, and the none queue for things which have not yet been rated.
          # The backfill route of the queues then, assuming we want people to rate the things that are not yet rated,
          #   but not at the expense of the experience, would be:
          # high => medium => none => low
          [{ name: 'high',
             elements: build_elements('h', 20),
             backfill: 'medium' },
           { name: 'medium',
             elements: build_elements('m', 20),
             backfill: 'none' },
           { name: 'low',
             elements: build_elements('l', 20),
             backfill: true },
           { name: 'none',
             elements: build_elements('n', 20),
             backfill: 'low' }]
        )
      end
      let(:pusher) do
        Qfill::Pusher.from_array_of_hashes(
          [{ name: 'first',
             list_ratios: {
               'high' => 0.5,
               'medium' => 0.1,
               'none' => 0.4
             },
             ratio: 1,
             preferred: %w[high none] },
           { name: 'second',
             ratio: 0.50 },
           { name: 'third',
             ratio: 0.25 }]
        )
      end
      let(:arguments) do
        {
          pusher: pusher,
          popper: popper,
          all_list_max: 100,
          strategy: :drain_to_empty
        }
      end

      describe '#new' do
        it 'does not raise any errors' do
          expect { described_class.new(arguments) }.not_to raise_error
        end
      end

      describe '#fill!' do
        it 'instantiates with pusher' do
          expect { described_class.new(arguments).fill! }.not_to raise_error
        end
      end

      context 'results' do
        context 'before fill!' do
          it 'calculates the correct popper total elements' do
            expect(manager.popper.count_all_elements).to eq(80)
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(60)
          end

          it 'calculates the correct pusher total elements' do
            expect(manager.pusher.count_all_elements).to eq(0)
          end
        end

        context 'after fill!' do
          before do
            manager.fill!
          end

          it 'calculates the correct leftover popper total elements' do
            expect(manager.popper.count_all_elements).to eq(20) # TODO???: With drain_to_empty the results do not exactly match the requested ratios.
          end

          it 'calculates the correct popper primary elements' do
            expect(manager.popper.count_primary_elements).to eq(0)
          end

          context 'when all_list_max is higher than count of all elements' do
            it 'reduces all_list_max to original count of all elements' do
              expect(manager.all_list_max).to eq(80)
            end

            it 'is greater than count of all elements in the results (pusher)' do
              expect(manager.all_list_max > manager.pusher.count_all_elements).to eq(true)
            end
          end

          context 'when all_list_max is lower than count of all elements' do
            let(:arguments) do
              {
                pusher: pusher,
                popper: popper,
                all_list_max: 4,
                strategy: :drain_to_empty
              }
            end

            it 'retains specified all_list_max' do
              expect(manager.all_list_max).to eq(4)
            end

            it 'is equal to count of all elements in the results (pusher)' do
              expect(manager.pusher.count_all_elements).to eq(manager.all_list_max)
            end
          end
        end
      end
    end
  end
end
