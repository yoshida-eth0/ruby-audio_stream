module AudioStream
  module Fx
    class Distortion
      def initialize(gain: 100, level: 0.1)
        @gain = gain
        @level = level
      end

      def process(input)
        streams = input.streams.map {|stream|
          dst = Vdsp::DoubleArray.new(input.window_size)
          Vdsp::UnsafeDouble.vclip(stream * @gain, 0, 1, -1.0, 1.0, dst, 0, 1, input.window_size)
          dst * @level
        }
        Buffer.new(*streams)
      end
    end
  end
end
