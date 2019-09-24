module AudioStream
  module Fx
    class Panning
      def initialize(pan: 0.0)
        @pan = pan

        l_gain = 1.0 - pan
        lr_gain = 0.0
        if 1.0<l_gain
          lr_gain = l_gain - 1.0
          l_gain = 1.0
        end

        r_gain = 1.0 + pan
        rl_gain = 0.0
        if 1.0<r_gain
          rl_gain = r_gain - 1.0
          r_gain = 1.0
        end

        normalize = [1.0 - pan, 1.0 + pan].max

        @r_gain = r_gain / normalize
        @rl_gain = rl_gain / normalize
        @l_gain = l_gain / normalize
        @lr_gain = lr_gain / normalize
      end

      def process(input)
        return input if @pan==0.0

        src = input.stereo.streams
        src0 = src[0]
        src1 = src[1]

        dst0 = Vdsp::DoubleArray.new(src0.length)
        Vdsp::UnsafeDouble.vsmsma(src0, 0, 1, @l_gain, src1, 0, 1, @lr_gain, dst0, 0, 1, src0.length)

        dst1 = Vdsp::DoubleArray.new(src1.length)
        Vdsp::UnsafeDouble.vsmsma(src0, 0, 1, @rl_gain, src1, 0, 1, @r_gain, dst1, 0, 1, src1.length)

        Buffer.new(dst0, dst1)
      end
    end
  end
end
