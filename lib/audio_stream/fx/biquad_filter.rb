module AudioStream
  module Fx
    class BiquadFilter
      DEFAULT_Q = 1.0 / Math.sqrt(2.0)

      def initialize(soundinfo)
        @soundinfo = soundinfo
        @biquads = [
          Vdsp::DoubleBiquad.new(1),
          Vdsp::DoubleBiquad.new(1),
        ]
      end

      def update_coef(*args, **kwargs)
        raise Error, "#{self.class.name}.update_coef is not implemented"
      end

      def process(input)
        channels = input.channels

        case channels
        when 1
          dst0 = @biquads[0].apply(input.streams[0])
          Buffer.new(dst0)
        when 2
          dst0 = @biquads[0].apply(input.streams[0])
          dst1 = @biquads[1].apply(input.streams[1])
          Buffer.new(dst0, dst1)
        end
      end

      def plot_data(width=500)
        b0 = @coef.b0
        b1 = @coef.b1
        b2 = @coef.b2
        a1 = @coef.a1
        a2 = @coef.a2

        noctaves = 10
        nyquist = @soundinfo.samplerate * 0.5

        freq = []
        x = []
        width.times {|i|
          f = i.to_f / width
          f = 2.0 ** (noctaves * (f - 1.0))
          freq << f
          x << (f * nyquist)
        }

        mag_res = []
        phase_res = []
        width.times {|i|
          omega = -Math::PI * freq[i]
          z = Complex(Math.cos(omega), Math.sin(omega))
          num = b0 + (b1 + b2 * z) * z
          den = 1 + (a1 + a2 * z) * z
          res = num / den

          mag_res << Decibel.mag(res.abs).db
          phase_res << 180 / Math::PI * Math.atan2(res.imag, res.real)
        }

        {x: x, magnitude: mag_res, phase: phase_res}
      end

      def plot(width=500)
        data = plot_data(width)

        mag_range = nil
        if -1.0<data[:magnitude].min && data[:magnitude].max<1.0
          mag_range = [-1.0, 1.0]
        end

        Plotly::Plot.new(
          data: [{x: data[:x], y: data[:magnitude], name: 'Magnitude', yaxis: 'y1'}, {x: data[:x], y: data[:phase], name: 'Phase', yaxis: 'y2'}],
          layout: {
            xaxis: {title: 'Frequency (Hz)', type: 'log'},
            yaxis: {side: 'left', title: 'Magnitude (dB)', range: mag_range, showgrid: false},
            yaxis2: {side: 'right', title: 'Phase (deg)', showgrid: false, overlaying: 'y'}
          }
        )
      end

    end
  end
end
