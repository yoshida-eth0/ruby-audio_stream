module AudioStream
  module Fx
    class AGain
      def initialize(level: 1.0)
        @level = level
      end

      def process(input)
        return input if @level==1.0

        streams = input.streams.map {|stream|
          stream.map {|f|
            f * @level
          }
        }
        Buffer.new(*streams)
      end
    end
  end
end
