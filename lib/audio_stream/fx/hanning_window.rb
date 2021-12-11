module AudioStream
  module Fx
    class HanningWindow
      include Singleton

      def process(input)
        streams = input.streams.map {|stream|
          stream * self.window(input.window_size)
        }

        Buffer.new(*streams)
      end

      def window(size)
        @window ||= {}
        @window[size] ||= Vdsp::DoubleArray.hann_window(size, Vdsp::FULL_WINDOW)
      end
    end
  end
end
