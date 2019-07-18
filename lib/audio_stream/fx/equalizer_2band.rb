module AudioStream
  module Fx
    class Equalizer2band
      include BangProcess

      def initialize(soundinfo, lowgain:, highgain:)
        @lowfreq = 400.0
        @lowgain = lowgain

        @highfreq = 4000.0
        @highgain = highgain

        @low_filter = LowShelfFilter.create(soundinfo, freq: @lowfreq, q: 1.0/Math.sqrt(2.0), gain: @lowgain)
        @high_filter = HighShelfFilter.create(soundinfo, freq: @highfreq, q: 1.0/Math.sqrt(2.0), gain: @highgain)
      end

      def process!(input)
        @low_filter.process!(input)
        @high_filter.process!(input)
      end
    end
  end
end
