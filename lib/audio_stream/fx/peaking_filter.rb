module AudioStream
  module Fx
    class PeakingFilter < BiquadFilter

      def update_coef(freq:, bandwidth:, gain:)
        if Decibel===gain
          gain = gain.db
        end

        omega = 2.0 * Math::PI * freq / @samplerate
        alpha = Math.sin(omega) * Math.sinh(Math.log(2.0) / 2.0 * bandwidth * omega / Math.sin(omega))
        a = 10.0 ** (gain / 40.0)

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
      # @param freq [Float] Cutoff frequency
      # @param bandwidth [Float] bandwidth (octave)
      # @param gain [AudioStream::Decibel] Amplification level at cutoff frequency
      def self.create(soundinfo, freq:, bandwidth: 1.0, gain: 40.0)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, bandwidth: bandwidth, gain: gain)

        filter
      end
    end
  end
end
