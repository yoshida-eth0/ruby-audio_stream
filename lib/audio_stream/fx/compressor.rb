module AudioStream
  module Fx
    class Compressor
      include BangProcess

      def initialize(threshold: 0.5, ratio: 0.5)
        @threshold = threshold
        @ratio = ratio
        @zoom = 1.0 / (@ratio * (1.0 - @threshold) + @threshold)
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        case channels
        when 1
          input.each_with_index {|f, i|
            sign = f.negative? ? -1 : 1
            f = f.abs
            if @threshold<f
              f = (f - @threshold) * @ratio + @threshold
            end
            input[i] = @zoom * f * sign
          }
        when 2
          input.each_with_index {|fa, i|
            input[i] = fa.map {|f|
              sign = f.negative? ? -1 : 1
              f = f.abs
              if @threshold<f
                f = (f - @threshold) * @ratio + @threshold
              end
              @zoom * f * sign
            }
          }
        end
      end
    end
  end
end
