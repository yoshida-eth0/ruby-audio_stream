module AudioStream
  module Fx
    class BiquadFilter
      include BangProcess

      FilterBuffer = Struct.new("FilterBuffer", :in1, :in2, :out1, :out2) do
        def self.create
          new(0.0, 0.0, 0.0, 0.0)
        end
      end

      FilterCoef = Struct.new("FilterCoef", :a0, :a1, :a2, :b0, :b1, :b2)

      def initialize(soundinfo)
        @samplerate = soundinfo.samplerate.to_f
        init_buffer
      end

      def init_buffer
        @filter_bufs = [FilterBuffer.create, FilterBuffer.create]
      end

      def update_coef(*args, **kwargs)
        raise Error, "#{self.class.name}.filter_coef is not implemented"
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        case channels
        when 1
          b = @filter_bufs[0]
          window_size.times {|i|
            input[i] = process_one(input[i], b)
          }
        when 2
          window_size.times {|i|
            input[i] = channels.times.map {|j|
              b = @filter_bufs[j]
              in0 = input[i][j]
              process_one(in0, b)
            }
          }
        end

        input
      end

      def process_mono(in0)
        process_one(in0, @filter_bufs[0])
      end

      def process_stereo(inp)
        [
          process_one(inp[0], @filter_bufs[0]),
          process_one(inp[1], @filter_bufs[1])
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
    end
  end
end
