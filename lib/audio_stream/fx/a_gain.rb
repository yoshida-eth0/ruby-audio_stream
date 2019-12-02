module AudioStream
  module Fx
    class AGain
      # @param level [AudioStream::Decibel] Amplification level
      def initialize(level:)
        if Decibel===level
          @level = level.mag
        else
          @level = Decibel.db(level).mag
        end
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
