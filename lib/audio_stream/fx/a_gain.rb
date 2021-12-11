module AudioStream
  module Fx
    class AGain
      # @param level [AudioStream::Decibel | Float] Amplification level (~0.0)
      def initialize(level:)
        @level = Decibel.db(level).mag
      end

      def process(input)
        return input if @level==1.0

        streams = input.streams.map {|stream|
          stream * @level
        }
        Buffer.new(*streams)
      end
    end
  end
end
