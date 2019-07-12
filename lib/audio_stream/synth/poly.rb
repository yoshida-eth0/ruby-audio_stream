module AudioStream
  module Synth
    class Poly

      attr_reader :oscs

      attr_reader :volume
      attr_reader :pan
      attr_reader :tune_semis
      attr_reader :tune_cents

      attr_reader :soundinfo

      # @param oscs [Osc] oscillator
      # @param volume [Float] master volume. mute=0.0 max=1.0
      # @param pan [Float] master pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
      # @param tune_semis [Integer] master pitch semitone
      # @param tune_cents [Integer] master pitch cent
      # @param soundinfo [SoundInfo]
      def initialize(oscs:, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, soundinfo:)
        @oscs = [oscs].flatten.compact

        @volume = Param.create(volume)
        @pan = Param.create(pan)

        @tune_semis = Param.create(tune_semis)
        @tune_cents = Param.create(tune_cents)

        @soundinfo = soundinfo

        @performs = {}
      end

      def next
        if 0<@performs.length
          bufs = @performs.values.map(&:next)

          # delete released note performs
          @performs.delete_if{|teno_num, per| per.released?}

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
