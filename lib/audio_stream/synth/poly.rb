module AudioStream
  module Synth
    class Poly

      attr_reader :volume
      attr_reader :pan
      attr_reader :tune_semis
      attr_reader :tune_cents

      attr_reader :oscs
      attr_reader :volume
      attr_reader :volume_mods

      def initialize(oscs: nil, volume: 1.0, volume_mods: nil, soundinfo:)
        #@oscs = [osc].flatten.compact
        @oscs = [Osc.new(soundinfo: soundinfo)]

        @volume = volume
        #@volume_mods = [vol_mods].flatten.compact
        @volume_mods = [Modulation::Adsr.new(
          attack: 0.1,
          hold: 0.1,
          decay: 0.4,
          sustain: 0.8,
          release: 0.5,
          soundinfo: soundinfo
        )]

        @pan = 0.0
        @pan_mods = []

        @tune_semis = 0
        @tune_cents = 0

        @soundinfo = soundinfo

        @performs = {}
      end

      def next
        if 0<@performs.length
          @performs.values.map(&:next).inject(:+)
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
