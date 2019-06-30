module AudioStream
  module Fx
    class HanningWindow
      include BangProcess

      def process!(input)
        window_size = input.size
        window_max = input.size - 1
        channels = input.channels

        period = 2 * Math::PI / window_max

        case channels
        when 1
          input.each_with_index {|f, i|
            input[i] *= 0.5 - 0.5 * Math.cos(i * period)
          }
        when 2
          input.each_with_index {|fa, i|
            gain = 0.5 - 0.5 * Math.cos(i * period)
            input[i] = fa.map {|f| f * gain}
          }
        end
      end
    end
  end
end
