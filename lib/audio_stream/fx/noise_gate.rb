module AudioStream
  module Fx
    class NoiseGate
      def initialize(threshold: 0.01)
        @threshold = threshold
        @window = HanningWindow.instance
      end

      def process(input)
        window_size = input.window_size
        channels = input.channels

        # fft
        input = @window.process(input)
        na = input.to_float_na
        fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

        fft.size.times {|i|
          if fft[i].abs < @threshold
            fft[i] = 0i
          end
        }
        wet_na = FFTW3.fft(fft, FFTW3::BACKWARD)

        Buffer.from_na(wet_na)
      end
    end
  end
end
