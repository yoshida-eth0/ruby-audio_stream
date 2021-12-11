module AudioStream
  module Fx
    class Tremolo
      # @param soundinfo [AudioStream::SoundInfo]
      # @param freq [AudioStream::Rate | Float] Tremolo speed (0.0~)
      # @param depth [Float] Tremolo depth (0.0~)
      def initialize(soundinfo, freq:, depth:)
        @freq = Rate.freq(freq)
        @depth = depth.to_f
        @phase = 0
        @period = @freq.sample_phase(soundinfo)
      end

      def process(input)
        window_size = input.window_size

        streams = input.streams.map {|stream|
          stream.map.with_index {|f, i|
            f * (1.0 + @depth * Math.sin((i + @phase) * @period))
          }
        }
        @phase = (@phase + window_size) % (window_size / @period)

        Buffer.new(*streams)
      end
    end
  end
end
