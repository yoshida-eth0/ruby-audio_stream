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

        @filter_coef = FilterCoef.new(a0, a1, a2, b0, b1, b2)
      end

      def self.create(soundinfo, freq:, q: nil)
        q ||= 1.0 / Math.sqrt(2)

        filter = new(soundinfo)
        filter.update_coef(freq: freq, q: q)

        filter
      end
    end
  end
end
