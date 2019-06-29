module AudioStream
  module Fx
    module BangProcess
      def process(input)
        output = input.clone
        process!(output)
        output
      end
    end
  end
end
