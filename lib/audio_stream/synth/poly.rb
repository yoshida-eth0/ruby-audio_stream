module AudioStream
  module Synth
    class Poly

      attr_reader :oscs
      attr_reader :amp
      attr_reader :processor

      attr_reader :quality
      attr_reader :soundinfo

      attr_reader :glide
      attr_accessor :pitch_bend

      # @param oscs [Osc] oscillator
      # @param amp [Amp] amplifier
      # @param soundinfo [SoundInfo]
      def initialize(oscs:, amp:, quality: Quality::LOW, soundinfo:)
        @oscs = [oscs].flatten.compact
        @amp = amp

        @quality = quality
        @soundinfo = soundinfo

        @processor = Processor.create(quality)
        @notes = {}
        @pitch_bend = 0.0
      end

      def next
        if 0<@notes.length
          bufs = @notes.values.map(&:next)

          # delete released notes
          @notes.delete_if {|note_num, note| note.released? }

          bufs.compact.inject(:+)
        else
          Buffer.float(@soundinfo.window_size, @soundinfo.channels)
        end
      end

      def note_on(tune)
        # Note Off
        note = @notes[tune.note_num]
        if note
          note.note_off!
        end

        # Note On
        note = Note.new(self, tune)
        @notes[tune.note_num] = note
      end

      def note_off(tune)
        # Note Off
        note = @notes[tune.note_num]
        if note
          note.note_off!
        end
      end
    end
  end
end
