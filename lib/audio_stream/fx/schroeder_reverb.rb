module AudioStream
  module Fx
    class SchroederReverb

      # @param soundinfo [AudioStream::SoundInfo]
      # @param dry [AudioStream::Decibel] dry gain
      # @param wet [AudioStream::Decibel] wet gain
      def initialize(soundinfo, dry: -1.0, wet: -20.0)
        @window_size = soundinfo.window_size
        @combs = [
          CombFilter.new(soundinfo, freq: Rate.msec(39.85), q: 0.871402),
          CombFilter.new(soundinfo, freq: Rate.msec(36.10), q: 0.882762),
          CombFilter.new(soundinfo, freq: Rate.msec(33.27), q: 0.891443),
          CombFilter.new(soundinfo, freq: Rate.msec(30.15), q: 0.901117),
        ]
        @allpasss = [
          AllPassFilter.create(soundinfo, freq: Rate.msec(5.0).freq(soundinfo), q: BiquadFilter::DEFAULT_Q),
          AllPassFilter.create(soundinfo, freq: Rate.msec(1.7).freq(soundinfo), q: BiquadFilter::DEFAULT_Q),
        ]

        @dry = Decibel.create(dry).mag
        @wet = Decibel.create(wet).mag
      end

      def process(input)
        window_size = input.window_size
        if @window_size!=window_size
          raise "window size is not match: impulse.size=#{@window_size} input.size=#{window_size}"
        end

        wets = @combs.map {|comb|
          comb.process(input)
        }
        wet = Buffer.merge(wets, average: true)

        @allpasss.each {|allpass|
          wet = allpass.process(wet)
        }

        streams = wet.streams.map.with_index {|wet_stream, i|
          dry_stream = input.streams[i]
          dst = Vdsp::DoubleArray.new(window_size)
          Vdsp::UnsafeDouble.vsmsma(dry_stream, 0, 1, @dry, wet_stream, 0, 1, @wet, dst, 0, 1, window_size)
          dst
        }

        Buffer.new(*streams)
      end
    end
  end
end
