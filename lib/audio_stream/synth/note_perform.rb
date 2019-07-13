module AudioStream
  module Synth
    class NotePerform

      attr_reader :synth
      attr_reader :tune

      def initialize(synth, tune)
        @synth = synth
        @oscs = synth.oscs.map {|osc|
          osc.generator(self)
        }

        @tune = tune
        @note_on = true
        @released = false
      end

      def next
        begin
          @oscs.map(&:next).inject(:+)
        rescue StopIteration => e
puts "note released: #{@tune.note_num}"
          @released = true
          nil
        end
      end

      def note_on?
        @note_on
      end

      def note_off!
        @note_on = false
      end

      def released?
        @released
      end
    end
  end
end
