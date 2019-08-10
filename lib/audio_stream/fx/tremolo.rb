module AudioStream
  module Fx
    class Tremolo
      def initialize(soundinfo, freq:, depth:)
        @samplerate = soundinfo.samplerate
        @freq = freq.to_f
        @depth = depth.to_f
        @phase = 0
      end

      def process(input)
        window_size = input.window_size
        period = 2 * Math::PI * @freq / @samplerate

        streams = input.streams.map {|stream|
          stream.map.with_index {|f, i|
            f * (1.0 + @depth * Math.sin((i + @phase) * period))
          }
        }
        @phase = (@phase + window_size) % (window_size / period)

        Buffer.new(*streams)
      end
    end
  end
end
