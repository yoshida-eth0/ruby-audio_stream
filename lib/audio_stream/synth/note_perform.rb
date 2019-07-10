module AudioStream
  module Synth
    class NotePerform

      attr_reader :volume_mods

      def initialize(synth, tune)
        @synth = synth
        @oscs = synth.oscs.map {|osc|
          osc.generator(self)
        }
        @volume_mods = synth.volume_mods.map {|mod|
          mod.generator(self)
        }

        @tune = tune
        @note_on = true
        @seek = 0
      end

      def next
        buf = @oscs.map(&:next).inject(:+)
        @seek += 1
        buf
      end

      def hz(semis: 0, cents: 0)
        @tune.hz(semis: @synth.tune_semis + semis, cents: @synth.tune_cents + cents)
      end

      def note_on?
        @note_on
      end

      def note_off!
        @note_on = false
      end

      def released?
        false
      end
    end
  end
end
