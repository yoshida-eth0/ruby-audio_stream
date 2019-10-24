module AudioStream
  module Fx
    class Compressor
      def initialize(threshold: 0.5, ratio: 0.5)
        @threshold = threshold
        @ratio = ratio
        @zoom = 1.0 / (@ratio * (1.0 - @threshold) + @threshold)
      end

      def process(input)
        streams = input.streams.map {|stream|
          sign = Vdsp::DoubleArray.new(input.window_size)
          Vdsp::UnsafeDouble.vlim(stream, 0, 1, 0.0, @zoom, sign, 0, 1, input.window_size)

          abs = stream.abs

          under = Vdsp::DoubleArray.new(input.window_size)
          Vdsp::UnsafeDouble.vclip(abs, 0, 1, 0.0, @threshold, under, 0, 1, input.window_size)

          over = Vdsp::DoubleArray.new(input.window_size)
          Vdsp::UnsafeDouble.vthr(abs, 0, 1, @threshold, over, 0, 1, input.window_size)
          over = (over - @threshold) * @ratio

          (under + over) * sign
        }
        Buffer.new(*streams)
      end
    end
  end
end
