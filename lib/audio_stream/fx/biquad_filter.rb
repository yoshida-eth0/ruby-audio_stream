module AudioStream
  module Fx
    class BiquadFilter
      FilterBuffer = Struct.new("FilterBuffer", :in1, :in2, :out1, :out2) do
        def self.create
          new(0.0, 0.0, 0.0, 0.0)
        end
      end

      FilterCoef = Struct.new("FilterCoef", :a0, :a1, :a2, :b0, :b1, :b2)

      DEFAULT_Q = 1.0 / Math.sqrt(2.0)

      def initialize(soundinfo)
        @samplerate = soundinfo.samplerate.to_f
        init_buffer
      end

      def init_buffer
        @filter_bufs = [FilterBuffer.create, FilterBuffer.create]
      end

      def update_coef(*args, **kwargs)
        raise Error, "#{self.class.name}.update_coef is not implemented"
      end

      def process(input)
        window_size = input.window_size
        channels = input.channels

        streams = input.streams.map.with_index {|stream, i|
          b = @filter_bufs[i]
          stream.map {|f|
            process_one(f, b)
          }
        }
        Buffer.new(*streams)
      end

      def process_mono(in0)
        process_one(in0, @filter_bufs[0])
      end

      def process_stereo(in0, in1)
        [
          process_one(in0, @filter_bufs[0]),
          process_one(in1, @filter_bufs[1])
        ]
      end

      def process_one(in0, b)
        c = @filter_coef
        out0 = c.b0/c.a0 * in0 + c.b1/c.a0 * b.in1 + c.b2/c.a0 * b.in2 - c.a1/c.a0 * b.out1 - c.a2/c.a0 * b.out2

        b.in2 = b.in1
        b.in1 = in0
        b.out2 = b.out1
        b.out1 = out0

        out0
      end

      def plot_data(width=500)
        c = @filter_coef

        b0 = c.b0 / c.a0
        b1 = c.b1 / c.a0
        b2 = c.b2 / c.a0
        a1 = c.a1 / c.a0
        a2 = c.a2 / c.a0

        noctaves = 10
        nyquist = @samplerate * 0.5

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

        Plotly::Plot.new(
          data: [{x: data[:x], y: data[:magnitude], name: 'Magnitude', yaxis: 'y1'}, {x: data[:x], y: data[:phase], name: 'Phase', yaxis: 'y2'}],
          layout: {
            xaxis: {title: 'Frequency (Hz)', type: 'log'},
            yaxis: {side: 'left', title: 'Magnitude (dB)', showgrid: false},
            yaxis2: {side: 'right', title: 'Phase (deg)', showgrid: false, overlaying: 'y'}
          }
        )
      end

    end
  end
end
