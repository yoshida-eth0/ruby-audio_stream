module AudioStream
  module Fx
    class Distortion
      # @param gain [AudioStream::Decibel | Float] input gain
      # @param level [AudioStream::Decibel | Float] output level
      def initialize(gain: 40.0, level: -20.0)
        @gain = Decibel.db(gain).mag
        @level = Decibel.db(level).mag
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
