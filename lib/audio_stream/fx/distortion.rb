module AudioStream
  module Fx
    class Distortion
      def initialize(gain: 100, level: 0.1)
        @gain = gain
        @level = level
      end

      def process(input)
        streams = input.streams.map {|stream|
          stream.map {|f|
            val = f * @gain
            if 1.0 < val
              val = 1.0
            elsif val < -1.0
              val = -1.0
            end
            val * @level
          }
        }
        Buffer.new(*streams)
      end
    end
  end
end
