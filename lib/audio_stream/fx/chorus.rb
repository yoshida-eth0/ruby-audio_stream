module AudioStream
  module Fx
    class Chorus
      include BangProcess

      def initialize(soundinfo)
        @soundinfo = soundinfo

        @depth = 100
        @rate = 0.25

        @delaybuf0 = RingBuffer.new(@depth * 3, 0.0)
        @delaybuf1 = RingBuffer.new(@depth * 3, 0.0)

        @phase = 0
        @speed = (2.0 * Math::PI * @rate) / @soundinfo.samplerate
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        window_size.times {|i|
          case channels
          when 1
            @delaybuf0.current = input[i]
            @delaybuf0.rotate
          when 2
            @delaybuf0.current = input[i][0]
            @delaybuf1.current = input[i][1]
            @delaybuf0.rotate
            @delaybuf1.rotate
          end

          tau = @depth * (Math.sin(@speed * (@phase + i)) + 1)
          t = i - tau

          m = t.floor
          delta = t - m

          case channels
          when 1
            wet = delta * @delaybuf0[i-m+1] + (1.0 - delta) * @delaybuf0[i-m]
            input[i] = (input[i] + wet) * 0.5
          when 2
            wet0 = delta * @delaybuf0[i-m+1] + (1.0 - delta) * @delaybuf0[i-m]
            wet1 = delta * @delaybuf1[i-m+1] + (1.0 - delta) * @delaybuf1[i-m]
            input[i] = [(input[i][0] + wet0) * 0.5, (input[i][1] + wet1) * 0.5]
          end
        }
        @phase = (@phase + window_size) % (window_size / @speed)
      end

      def lerp(start, stop, step)
        (stop * step) + (start * (1.0 - step))
      end
    end
  end
end
