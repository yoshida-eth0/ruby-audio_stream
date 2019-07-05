module AudioStream
  module Fx
    class MonoToStereo
      def process(input)
        case input.channels
        when 1
          output = Buffer.float(input.size, 2)
          input.each_with_index {|f, i|
            output[i] = [f, f]
          }
          output
        when 2
          input.clone
        end
      end
    end
  end
end
