module AudioStream
  module Fx
    class Panning
      include BangProcess

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

      def process!(input)
        return if @pan==0.0

        case input.channels
        when 1
        when 2
          input.each_with_index {|fa, i|
            l = (fa[0] * @l_gain + fa[1] * @lr_gain) / @normalize
            r = (fa[1] * @r_gain + fa[0] + @rl_gain) / @normalize
            input[i] = [l, r]
          }
        end
      end
    end
  end
end
