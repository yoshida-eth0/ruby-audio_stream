module AudioStream
  module Fx
    class HanningWindow
      include Singleton

      def process(input)
        window_size = input.window_size
        window_max = input.window_size - 1
        channels = input.channels

        period = 2 * Math::PI / window_max

        streams = input.streams.map {|stream|
          stream.map.with_index {|f, i|
            f * (0.5 - 0.5 * Math.cos(i * period))
          }
        }

        Buffer.new(*streams)
      end
    end
  end
end
