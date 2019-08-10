module AudioStream
  module Fx
    class Panning
      def initialize(pan: 0.0)
        @pan = pan

        @l_gain = 1.0 - pan
        @lr_gain = 0.0
        if 1.0<@l_gain
          @lr_gain = @l_gain - 1.0
          @l_gain = 1.0
        end

        @r_gain = 1.0 + pan
        @rl_gain = 0.0
        if 1.0<@r_gain
          @rl_gain = @r_gain - 1.0
          @r_gain = 1.0
        end

        @normalize = [1.0 - pan, 1.0 + pan].max
      end

      def process(input)
        return input if @pan==0.0

        input = input.stereo
        src = input.streams
        src0 = src[0]
        src1 = src[1]

        output = Buffer.create_stereo(input.window_size)
        dst = output.streams
        dst0 = dst[0]
        dst1 = dst[1]

        input.window_size.times {|i|
          l = (src0[i] * @l_gain + src1[i] * @lr_gain) / @normalize
          r = (src1[i] * @r_gain + src0[i] * @rl_gain) / @normalize
          dst0[i] = l
          dst1[i] = r
        }
        output
      end
    end
  end
end
