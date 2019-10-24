module AudioStream
  module Fx
    class CombFilter

      def initialize(soundinfo, freq:, q:)
        @window_size = soundinfo.window_size
        @samplerate = soundinfo.samplerate
        @delaysample = (soundinfo.samplerate.to_f / freq).round
        @q = q

        @delaybufs = [
          Vdsp::DoubleArray.new(soundinfo.window_size + @delaysample),
          Vdsp::DoubleArray.new(soundinfo.window_size + @delaysample),
        ]
      end

      def process(input)
        window_size = input.window_size
        if @window_size!=window_size
          raise "window size is not match: impulse.size=#{@window_size} input.size=#{window_size}"
        end

        streams = input.streams.map.with_index {|src, i|
          buf = @delaybufs[i]

          Vdsp::UnsafeDouble.copy(buf, window_size, 1, buf, 0, 1, @delaysample)
          if @delaysample<window_size
            Vdsp::UnsafeDouble.vclr(buf, window_size, 1, @delaysample)
          end
          Vdsp::UnsafeDouble.vsmsma(src, 0, 1, 1.0, buf, 0, 1, @q, buf, @delaysample, 1, window_size)
          dst = buf[@delaysample, window_size]

          dst
        }

        Buffer.new(*streams)
      end
    end
  end
end
