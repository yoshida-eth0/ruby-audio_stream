module AudioStream
  module Fx
    class HighShelfFilter < BiquadFilter

      def initialize(soundinfo, freq:, q: nil, gain: 1.0)
        super()
        @samplerate = soundinfo.samplerate.to_f
        @freq = freq
        @q = q || 1.0 / Math.sqrt(2)
        @gain = gain

        filter_coef
      end

      def filter_coef
        omega = 2.0 * Math::PI * @freq / @samplerate
        alpha = Math.sin(omega) / (2.0 * @q)
        a = 10.0 ** (@gain / 40.0)
        beta = Math.sqrt(a) / @q

        a0 = (a+1) - (a-1) * Math.cos(omega) + beta * Math.sin(omega)
        a1 = 2.0 * ((a-1) - (a+1) * Math.cos(omega))
        a2 = (a+1) - (a-1) * Math.cos(omega) - beta * Math.sin(omega)
        b0 = a * ((a+1) + (a-1) * Math.cos(omega) + beta * Math.sin(omega))
        b1 = -2.0 * a * ((a-1) + (a+1) * Math.cos(omega))
        b2 = a * ((a+1) + (a-1) * Math.cos(omega) - beta * Math.sin(omega))

        @filter_coef = FilterCoef.new(a0, a1, a2, b0, b1, b2)
      end
    end
  end
end
