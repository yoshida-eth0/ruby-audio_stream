module AudioStream
  module Fx
    class Tremolo
      include BangProcess

      def initialize(soundinfo, freq:, depth:)
        @samplerate = soundinfo.samplerate
        @freq = freq.to_f
        @depth = depth.to_f
        @phase = 0
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        period = 2 * Math::PI * @freq / @samplerate

        case channels
        when 1
          input.each_with_index {|f, i|
            input[i] *= 1.0 + @depth * Math.sin((i + @phase) * period)
          }
        when 2
          input.each_with_index {|fa, i|
            gain = 1.0 + @depth * Math.sin((i + @phase) * period)
            input[i] = fa.map {|f| f * gain}
          }
        end
        @phase = (@phase + window_size) % (window_size / period)
      end
    end
  end
end
