module AudioStream
  module Fx
    class Phaser

      def initialize(soundinfo, rate:, depth:, freq:, dry: 0.5, wet: 0.5)
        @soundinfo = soundinfo

        @filters = [
          AllPassFilter.new(soundinfo),
          AllPassFilter.new(soundinfo),
        ]

        @speed = 2.0 * Math::PI * rate / @soundinfo.samplerate
        @phase = 0

        @depth = depth
        @freq = freq

        @dry = dry
        @wet = wet
      end

      def process(input)
        window_size = input.window_size
        @phase = (@phase + @speed * window_size) % (window_size / @speed)

        a = Math.sin(@phase) * 0.5 + 0.5
        apf_freq = @freq * (1.0 + a * @depth)

        wet = input
        @filters.each {|filter|
          filter.update_coef(freq: apf_freq, q: BiquadFilter::DEFAULT_Q)
          wet = filter.process(wet)
        }

        streams = wet.streams.map.with_index {|wet_stream, i|
          dry_stream = input.streams[i]
          dry_stream * @dry + wet_stream * @wet
        }

        Buffer.new(*streams)
      end
    end
  end
end
