module AudioStream
  module Fx
    class AllPassFilter < BiquadFilter

      def update_coef(freq:, q:)
        omega = 2.0 * Math::PI * freq / @samplerate
        alpha = Math.sin(omega) / (2.0 * q)

        a0 = 1.0 + alpha
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha
        b0 = 1.0 - alpha
        b1 = -2.0 * Math.cos(omega)
        b2 = 1.0 + alpha

        @coef = Vdsp::Biquad::Coefficient.new(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)
        @biquads.each {|biquad|
          biquad.coefficients = @coef
        }
      end

      def self.create(soundinfo, freq:, q: DEFAULT_Q)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, q: q)

        filter
      end
    end
  end
end
