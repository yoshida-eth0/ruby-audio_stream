module AudioStream
  module Fx
    class StereoToMono
      def process(input)
        case input.channels
        when 1
          input.clone
        when 2
          output = Buffer.float(input.size, 1)
          input.each_with_index {|fa, i|
            output[i] = fa.sum / 2.0
          }
          output
        end
      end
    end
  end
end
