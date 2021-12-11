module AudioStream
  module Fx
    class HighShelfFilter < BiquadFilter

      def update_coef(freq:, q:, gain:)
        freq = Rate.freq(freq)
        gain = Decibel.db(gain)

        omega = freq.sample_phase(@soundinfo)
        alpha = Math.sin(omega) / (2.0 * q)
        a = Decibel.db(gain.db / 2.0).mag
        beta = Math.sqrt(a) / q

        a0 = (a+1) - (a-1) * Math.cos(omega) + beta * Math.sin(omega)
        a1 = 2.0 * ((a-1) - (a+1) * Math.cos(omega))
        a2 = (a+1) - (a-1) * Math.cos(omega) - beta * Math.sin(omega)
        b0 = a * ((a+1) + (a-1) * Math.cos(omega) + beta * Math.sin(omega))
        b1 = -2.0 * a * ((a-1) + (a+1) * Math.cos(omega))
        b2 = a * ((a+1) + (a-1) * Math.cos(omega) - beta * Math.sin(omega))

        @coef = Vdsp::Biquad::Coefficient.new(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)
        @biquads.each {|biquad|
          biquad.coefficients = @coef
        }
      end

      # @param soundinfo [AudioStream::SoundInfo]
      # @param freq [AudioStream::Rate | Float] Cutoff frequency
      # @param q [Float] Quality factor
      # @param gain [AudioStream::Decibel | Float] Amplification level at cutoff frequency
      def self.create(soundinfo, freq:, q: DEFAULT_Q, gain: 1.0)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, q: q, gain: gain)

        filter
      end
    end
  end
end
