module AudioStream
  module Fx
    class BandPassFilter < BiquadFilter

      def initialize(soundinfo, freq:, bandwidth: 1.0)
        super()
        @samplerate = soundinfo.samplerate.to_f
        @freq = freq
        @bandwidth = bandwidth

        filter_coef
      end

      def filter_coef
        omega = 2.0 * Math::PI * @freq / @samplerate
        alpha = Math.sin(omega) * Math.sinh(Math.log(2.0) / 2.0 * @bandwidth * omega / Math.sin(omega))

        a0 = 1.0 + alpha
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha
        b0 = alpha
        b1 = 0.0
        b2 = -alpha

        @filter_coef = FilterCoef.new(a0, a1, a2, b0, b1, b2)
      end
    end
  end
end
