module AudioStream
  module Fx
    class SchroederReverb

      def initialize(soundinfo, time:, dry: 1.0, wet: 1.0)
        @window_size = soundinfo.window_size
        @combs = [
          CombFilter.new(soundinfo, freq: ms2freq(39.85 / 2.0 * time), q: 0.871402),
          CombFilter.new(soundinfo, freq: ms2freq(36.10 / 2.0 * time), q: 0.882762),
          CombFilter.new(soundinfo, freq: ms2freq(33.27 / 2.0 * time), q: 0.891443),
          CombFilter.new(soundinfo, freq: ms2freq(30.15 / 2.0 * time), q: 0.901117),
        ]
        @allpasss = [
          AllPassFilter.create(soundinfo, freq: ms2freq(5.0), q: 0.7),
          AllPassFilter.create(soundinfo, freq: ms2freq(1.7), q: 0.7),
        ]
      end

      def process(input)
        window_size = input.window_size
        if @window_size!=window_size
          raise "window size is not match: impulse.size=#{@window_size} input.size=#{window_size}"
        end

        outputs = @combs.map {|comb|
          comb.process(input)
        }
        output = Buffer.merge(outputs, average: true)

        @allpasss.each {|allpass|
          output = allpass.process(output)
        }

        output
      end

      def ms2freq(ms)
        1.0 / (ms / 1000.0)
      end
    end
  end
end
