module AudioStream
  module Fx
    class Phaser

      # @param soundinfo [AudioStream::SoundInfo]
      # @param rate [AudioStream::Rate | Float] modulation speed
      # @param depth [Float] frequency modulation depth
      # @param freq [Float] Base cutoff frequency
      # @param dry [AudioStream::Decibel] dry gain
      # @param wet [AudioStream::Decibel] wet gain
      def initialize(soundinfo, rate:, depth:, freq:, dry: -6.0, wet: -6.0)
        @soundinfo = soundinfo

        @filters = [
          AllPassFilter.new(soundinfo),
          AllPassFilter.new(soundinfo),
        ]

        rate = Rate.create(rate)
        @speed = rate.frame_phase(soundinfo)
        @phase = 0

        @depth = depth
        @freq = freq

        @dry = Decibel.create(dry).mag
        @wet = Decibel.create(wet).mag
      end

      def process(input)
        window_size = input.window_size
        @phase = (@phase + @speed) % (2.0 * Math::PI)

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
