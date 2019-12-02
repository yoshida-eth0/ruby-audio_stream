module AudioStream
  module Fx
    class BandPassFilter < BiquadFilter

      def update_coef(freq:, bandwidth:)
        omega = 2.0 * Math::PI * freq / @samplerate
        alpha = Math.sin(omega) * Math.sinh(Math.log(2.0) / 2.0 * bandwidth * omega / Math.sin(omega))

        a0 = 1.0 + alpha
        a1 = -2.0 * Math.cos(omega)
        a2 = 1.0 - alpha
        b0 = alpha
        b1 = 0.0
        b2 = -alpha

        @coef = Vdsp::Biquad::Coefficient.new(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)
        @biquads.each {|biquad|
          biquad.coefficients = @coef
        }
      end

      # @param soundinfo [AudioStream::SoundInfo]
      # @param freq [Float] Center frequency
      # @param bandwidth [Float] bandwidth (octave)
      def self.create(soundinfo, freq:, bandwidth: 1.0)
        filter = new(soundinfo)
        filter.update_coef(freq: freq, bandwidth: bandwidth)

        filter
      end
    end
  end
end
