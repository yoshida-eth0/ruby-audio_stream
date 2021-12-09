module AudioStream
  module Fx
    class Delay
      # @param soundinfo [AudioStream::SoundInfo]
      # @param time [AudioStream::Rate | Float] delay time
      # @param level [AudioStream::Decibel | Float] wet gain
      # @param feedback [AudioStream::Decibel | Float] feedback level
      def initialize(soundinfo, time:, level:, feedback:)
        time = Rate.create(time)
        @level = Decibel.create(level).mag
        @feedback = Decibel.create(feedback).mag

        @delaysample = time.sample(soundinfo).round
        @delaybuf0 = Array.new(@delaysample, 0.0)
        @delaybuf1 = Array.new(@delaysample, 0.0)
        @seek = 0
      end

      def process(input)
        window_size = input.window_size
        channels = input.channels

        src0 = input.streams[0]
        src1 = input.streams[1]

        case channels
        when 1
          output = Buffer.create_mono(window_size)
          dst0 = output.streams[0]

          src0.each_with_index {|f, i|
            tmp0 = f + @level * @delaybuf0[@seek]
            @delaybuf0[@seek] = f + @feedback * @delaybuf0[@seek]
            dst0[i] = tmp0
            @seek = (@seek + 1) % @delaysample
          }
          output
        when 2
          output = Buffer.create_stereo(window_size)
          dst0 = output.streams[0]
          dst1 = output.streams[1]

          window_size.times {|i|
            tmp0 = src0[i] + @level * @delaybuf0[@seek]
            tmp1 = src1[i] + @level * @delaybuf1[@seek]

            @delaybuf0[@seek] = src0[i] + @feedback * @delaybuf0[@seek]
            @delaybuf1[@seek] = src1[i] + @feedback * @delaybuf1[@seek]

            dst0[i] = tmp0
            dst1[i] = tmp1

            @seek = (@seek + 1) % @delaysample
          }
          output
        end
      end
    end
  end
end
