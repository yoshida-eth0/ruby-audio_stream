module AudioStream
  module Synth
    class Tune
      NOTE_TABLE = [:"C", :"C#/Db", :"D", :"D#/Eb", :"E", :"F", :"F#/Gb", :"G", :"G#/Ab", :"A", :"A#/Bb", :"B"].freeze

      attr_reader :note_num

      def initialize(note_num)
        @note_num = note_num.to_i
      end

      def hz(semis: 0, cents: 0)
        6.875 * (2 ** ((@note_num + semis + (cents / 100.0) + 3) / 12.0))
      end

      def note_name
        NOTE_TABLE[(@note_num) % 12]
      end

      def octave_num
        (@note_num / 12) - 1
      end

      def self.create(name, octave)
        name = name.to_s
        octave = octave.to_i

        note_index = NOTE_TABLE.index(name)
        if !note_index
          raise Error, "not found note name: #{name}"
        end

        num = (octave + 1) * 12 + note_index
        if num<0
          raise Error, "octave #{octave} outside of tune"
        end

        new(num)
      end
    end
  end
end
