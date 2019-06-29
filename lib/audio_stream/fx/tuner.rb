module AudioStream
  module Fx
    class Tuner

      Tune = Struct.new("Tune", :freq, :note_num, :note, :octave, :diff, :gain, keyword_init: true)

      FREQ_TABLE = 10.times.map {|i|
        a = 13.75 * 2 ** i
        12.times.map {|j|
          a * (2 ** (j / 12.0))
        }
      }.flatten.freeze

      NOTE_TABLE = ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"].freeze
        
      def initialize(soundinfo, window: nil)
        @samplerate = soundinfo.samplerate
        @window = window || HanningWindow.new
      end

      def process(input)
        window_size = input.size

        # mono window
        input = StereoToMono.new.process(input)
        @window.process!(input)

        gain = input.to_a.flatten.max
        freq = nil

        if 0.01<gain
          # fft
          na = NArray.float(1, window_size)
          na[0...na.size] = input.to_a
          fft = FFTW3.fft(na, FFTW3::FORWARD)

          amp = fft.map {|c|
            c.real**2 + c.imag**2
          }.real.to_a.flatten

          # peak
          i = amp.index(amp.max)

          if window_size/2<i
            j = window_size - i
            if (amp[i]-amp[j]).abs<=0.0000001
              i = j
            end
          end

          # freq
          freq_rate = @samplerate / window_size

          if 0<i && i<window_size-1
            freq_sum = amp[i-1] * (i-1) * freq_rate
            freq_sum += amp[i] * i * freq_rate
            freq_sum += amp[i+1] * (i+1) * freq_rate

            amp_sum = amp[i-1] + amp[i] + amp[i+1]

            freq = freq_sum / amp_sum
          else
            freq = i * freq_rate
          end

          struct(freq)
        else
          Tune.new
        end
      end

      def struct(freq)
        index = FREQ_TABLE.bsearch_index {|x| x>=freq}
        if !index || FREQ_TABLE.length<=index+1
          return Tune.new
        end

        if 0<index && freq-FREQ_TABLE[index-1] < FREQ_TABLE[index]-freq
          diff = (freq-FREQ_TABLE[index-1]) / (FREQ_TABLE[index]-FREQ_TABLE[index-1]) * 100
          index -= 1
        else
          diff = (freq-FREQ_TABLE[index]) / (FREQ_TABLE[index+1]-FREQ_TABLE[index]) * 100
        end
        note_num = index + 9
        note = NOTE_TABLE[index%12]
        octave = (index-3)/12

        Tune.new(
          freq: freq,
          note_num: note_num,
          note: note,
          octave: octave,
          diff: diff
        )
      end
    end
  end
end
