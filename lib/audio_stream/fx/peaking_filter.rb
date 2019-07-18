module AudioStream
  module Fx
    class PeakingFilter < BiquadFilter

      def update_coef(freq:, bandwidth:, gain:)
        omega = 2.0 * Math::PI * freq / @samplerate
        alpha = Math.sin(omega) * Math.sinh(Math.log(2.0) / 2.0 * bandwidth * omega / Math.sin(omega))
        a = 10.0 ** (gain / 40.0)

        a0 = 1.0 + alpha / a
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha / a
        b0 = 1.0 + alpha * a
        b1 = -2.0 * Math.cos(omega)
        b2 = 1.0 + alpha * a

        @filter_coef = FilterCoef.new(a0, a1, a2, b0, b1, b2)
      end

      def self.create(soundinfo, freq:, bandwidth: 1.0, gain: 40.0)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, bandwidth: bandwidth, gain: gain)

        filter
      end
    end
  end
end
