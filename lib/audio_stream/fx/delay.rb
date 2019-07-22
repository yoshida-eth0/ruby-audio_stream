module AudioStream
  module Fx
    class Delay
      include BangProcess

      def initialize(soundinfo, time:, level:, feedback:)
        @time = time
        @level = level
        @feedback = feedback

        @delaysample = (soundinfo.samplerate * time).round
        @delaybuf0 = Array.new(@delaysample, 0.0)
        @delaybuf1 = Array.new(@delaysample, 0.0)
        @seek = 0
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        case channels
        when 1
          input.each_with_index {|f, i|
            tmp0 = input[i] + @level * @delaybuf0[@seek]
            @delaybuf0[@seek] = input[i] + @feedback * @delaybuf0[@seek]
            input[i] = tmp0
            @seek = (@seek + 1) % @delaysample
          }
        when 2
          input.each_with_index {|fa, i|
            tmp0 = input[i][0] + @level * @delaybuf0[@seek]
            tmp1 = input[i][1] + @level * @delaybuf1[@seek]

            @delaybuf0[@seek] = input[i][0] + @feedback * @delaybuf0[@seek]
            @delaybuf1[@seek] = input[i][1] + @feedback * @delaybuf1[@seek]

            input[i] = [tmp0, tmp1]

            @seek = (@seek + 1) % @delaysample
          }
        end
      end
    end
  end
end
