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
          stream.map {|f|
            sign = f.negative? ? -1 : 1
            f = f.abs
            if @threshold<f
              f = (f - @threshold) * @ratio + @threshold
            end
            @zoom * f * sign
          }
        }
        Buffer.new(*streams)
      end
    end
  end
end
