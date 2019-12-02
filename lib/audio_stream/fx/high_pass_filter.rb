module AudioStream
  module Fx
    class HighPassFilter < BiquadFilter

      def update_coef(freq:, q:)
        omega = 2.0 * Math::PI * freq / @samplerate
        alpha = Math.sin(omega) / (2.0 * q)

        a0 = 1.0 + alpha
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha
        b0 = (1.0 + Math.cos(omega)) / 2.0 
        b1 = -(1.0 + Math.cos(omega))
        b2 = (1.0 + Math.cos(omega)) / 2.0 

        @coef = Vdsp::Biquad::Coefficient.new(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)
        @biquads.each {|biquad|
          biquad.coefficients = @coef
        }
      end

      # @param soundinfo [AudioStream::SoundInfo]
      # @param freq [Float] Cutoff frequency
      # @param q [Float] Quality factor
      def self.create(soundinfo, freq:, q: DEFAULT_Q)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, q: q)

        filter
      end
    end
  end
end
