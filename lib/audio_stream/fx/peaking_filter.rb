module AudioStream
  module Fx
    class PeakingFilter < BiquadFilter

      def update_coef(freq:, bandwidth:, gain:)
        omega = freq.sample_phase(@soundinfo)
        alpha = Math.sin(omega) * Math.sinh(Math.log(2.0) / 2.0 * bandwidth * omega / Math.sin(omega))
        a = Decibel.db(gain.db / 2.0).mag

        a0 = 1.0 + alpha / a
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha / a
        b0 = 1.0 + alpha * a
        b1 = -2.0 * Math.cos(omega)
        b2 = 1.0 - alpha * a

        @coef = Vdsp::Biquad::Coefficient.new(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)
        @biquads.each {|biquad|
          biquad.coefficients = @coef
        }
      end

      # @param soundinfo [AudioStream::SoundInfo]
      # @param freq [AudioStream::Rate | Float] Cutoff frequency
      # @param bandwidth [Float] bandwidth (octave)
      # @param gain [AudioStream::Decibel | Float] Amplification level at cutoff frequency
      def self.create(soundinfo, freq:, bandwidth: 1.0, gain: 40.0)
        filter = new(soundinfo)
        freq = Rate.freq(freq)
        gain = Decibel.db(gain)
        filter.update_coef(freq: freq, bandwidth: bandwidth, gain: gain)

        filter
      end
    end
  end
end
