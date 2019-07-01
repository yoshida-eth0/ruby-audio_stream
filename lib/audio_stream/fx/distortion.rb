module AudioStream
  module Fx
    class Distortion
      include BangProcess

      def initialize(gain: 100, level: 0.1)
        @gain = gain
        @level = level
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        case channels
        when 1
          input.each_with_index {|f, i|
            val = input[i] * @gain
            if 1.0 < val
              val = 1.0
            elsif val < -1.0
              val = -1.0
            end
            input[i] = val * @level
          }
        when 2
          input.each_with_index {|fa, i|
            input[i] = fa.map {|f|
              val = f * @gain
              if 1.0 < val
                val = 1.0
              elsif val < -1.0
                val = -1.0
              end
              val * @level
            }
          }
        end
      end
    end
  end
end
