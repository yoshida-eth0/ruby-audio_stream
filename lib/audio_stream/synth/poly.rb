module AudioStream
  module Synth
    class Poly

      attr_reader :oscs
      attr_reader :amp

      attr_reader :quality
      attr_reader :soundinfo

      # @param oscs [Osc] oscillator
      # @param amp [Amp] amplifier
      # @param soundinfo [SoundInfo]
      def initialize(oscs:, amp:, quality: Quality::LOW, soundinfo:)
        @oscs = [oscs].flatten.compact
        @amp = amp

        @quality = quality
        @soundinfo = soundinfo

        @performs = {}
      end

      def next
        if 0<@performs.length
          bufs = @performs.values.map(&:next)

          # delete released note performs
          @performs.delete_if{|note_num, per| per.released?}

          bufs.compact.inject(:+)
        else
          Buffer.float(@soundinfo.window_size, @soundinfo.channels)
        end
      end

      def note_on(tune)
        # Note Off
        perform = @performs[tune.note_num]
        if perform
          perform.note_off!
        end

        # Note On
        perform = NotePerform.new(self, tune)
        @performs[tune.note_num] = perform
      end

      def note_off(tune)
        # Note Off
        perform = @performs[tune.note_num]
        if perform
          perform.note_off!
        end
      end
    end
  end
end
