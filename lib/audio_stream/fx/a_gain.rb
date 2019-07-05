module AudioStream
  module Fx
    class AGain
      include BangProcess

      def initialize(level: 1.0)
        @level = level
      end

      def process!(input)
        return if @level==1.0

        case input.channels
        when 1
          input.each_with_index {|f, i|
            input[i] = f * @level
          }
        when 2
          input.each_with_index {|fa, i|
            input[i] = fa.map {|f| f * @level}
          }
        end
      end
    end
  end
end
