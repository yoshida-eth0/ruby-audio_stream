module AudioStream
  module Fx
    class Chorus
      def initialize(soundinfo, depth: 100, rate: 0.25)
        @soundinfo = soundinfo

        @depth = depth
        @rate = rate

        @delaybufs = [
          RingBuffer.new(@depth * 3, 0.0),
          RingBuffer.new(@depth * 3, 0.0)
        ]

        @phase = 0
        @speed = (2.0 * Math::PI * @rate) / @soundinfo.samplerate
      end

      def process(input)
        window_size = input.window_size
        channels = input.channels

        streams = channels.times.map {|ch|
          delaybuf = @delaybufs[ch]
          input.streams[ch].map.with_index {|f, i|
            tau = @depth * (Math.sin(@speed * (@phase + i)) + 1)
            t = i - tau

            m = t.floor
            delta = t - m

            wet = delta * delaybuf[i-m+1] + (1.0 - delta) * delaybuf[i-m]
            f = (f + wet) * 0.5

            delaybuf.current = f
            delaybuf.rotate

            f
          }
        }
        @phase = (@phase + window_size) % (window_size / @speed)

        Buffer.new(*streams)
      end

      def lerp(start, stop, step)
        (stop * step) + (start * (1.0 - step))
      end
    end
  end
end
