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
        na = @window.process(input).to_float_na
        fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

        # noise gate
        fft.size.times {|i|
          if @threshold <= fft[i].abs
            fft[i] = 0i
          end
        }
        wet_na = FFTW3.fft(fft, FFTW3::BACKWARD)
        noise = Buffer.from_na(wet_na)

        input - noise
      end
    end
  end
end
