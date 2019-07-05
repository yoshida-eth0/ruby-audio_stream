module AudioStream
  module Fx
    class Equalizer3band
      include BangProcess

      def initialize(soundinfo, lowgain:, midgain:, highgain:)
        @lowfreq = 400.0
        @lowgain = lowgain

        @midfreq = 1000.0
        @midgain = midgain

        @highfreq = 4000.0
        @highgain = highgain

        @low_filter = LowShelfFilter.new(soundinfo, freq: @lowfreq, q: 1.0/Math.sqrt(2.0), gain: @lowgain)
        @mid_filter = PeakingFilter.new(soundinfo, freq: @midfreq, bandwidth: 1.0/Math.sqrt(2.0), gain: @midgain)
        @high_filter = HighShelfFilter.new(soundinfo, freq: @highfreq, q: 1.0/Math.sqrt(2.0), gain: @highgain)
      end

      def process!(input)
        @low_filter.process!(input)
        @mid_filter.process!(input)
        @high_filter.process!(input)
      end
    end
  end
end
