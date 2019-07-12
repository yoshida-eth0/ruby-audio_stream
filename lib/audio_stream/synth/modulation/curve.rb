module AudioStream
  module Synth
    module Modulation
      module Curve
        Straight = ->(x) { x }
        EaseIn = ->(x) { x ** 2 }
        EaseOut = ->(x) { x * (2 - x) }
      end
    end
  end
end
