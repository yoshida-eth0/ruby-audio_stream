module AudioStream
  module Synth
    class Note

      attr_reader :synth
      attr_reader :tune

      def initialize(synth, tune)
        @synth = synth
        @processors = synth.oscs.map {|osc|
          synth.processor.generator(osc, self)
        }

        @tune = tune
        @note_on = true
        @released = false
      end

      def next
        begin
          @processors.map(&:next).inject(:+)
        rescue StopIteration => e
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
