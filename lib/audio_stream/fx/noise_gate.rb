module AudioStream
  module Fx
    class NoiseGate
      include BangProcess

      def initialize(threshold: 0.01)
        @threshold = threshold
        @window = HanningWindow.new
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        # fft
        @window.process!(input)
        na = NArray.float(channels, window_size)
        na[0...na.size] = input.to_a.flatten
        fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

        fft.size.times {|i|
          if fft[i].abs < @threshold
            fft[i] = 0i
          end
        }

        wet_na = FFTW3.fft(fft, FFTW3::BACKWARD)

        case channels
        when 1
          window_size.times {|i|
            input[i] = wet_na[i].real
          }
        when 2
          window_size.times {|i|
            wet1 = wet_na[i*2].real
            wet2 = wet_na[(i*2)+1].real

            input[i] = [wet1, wet2]
          }
        end
      end
    end
  end

  NArray.include Enumerable
end
