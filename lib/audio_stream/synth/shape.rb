module AudioStream
  module Synth
    module Shape
      Sine = ->(phase) { Math.sin(phase * 2 * Math::PI) }
      Sawtooth = ->(phase) { ((phase + 0.5) % 1) * 2 - 1 }
      Square = ->(phase) { 0.5<=((phase + 0.5) % 1) ? 1.0 : -1.0 }
      Triangle = ->(phase) {
        t = ((phase*4).floor % 4);
        t==0 ? (phase % 0.5)*4 :
        t==1 ? (2-(phase % 0.5)*4) :
        t==2 ? (-(phase % 0.5)*4) : (phase % 0.5)*4-2
      }
      WhiteNoise = ->(phase) { Random.rand(-1.0...1.0) }

      self.constants.tap {|consts|
        consts.each {|a|
          consts.each {|b|
            if a!=b
              eval "#{a}#{b} = ->(phase) {
                        (#{a}[phase] + #{b}[phase]) / 2 }"
            end
          }
        }
      }

    end
  end
end
