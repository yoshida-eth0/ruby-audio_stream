module AudioStream
  module Fx
    class Equalizer3band
      include BangProcess

      def initialize(soundinfo, lowfreq: 400.0, lowgain:, midfreq: 1000.0, midgain:, highfreq: 4000.0, highgain:)
        @low_filter = LowShelfFilter.create(soundinfo, freq: lowfreq, q: 1.0/Math.sqrt(2.0), gain: lowgain)
        @mid_filter = PeakingFilter.create(soundinfo, freq: midfreq, bandwidth: 1.0/Math.sqrt(2.0), gain: midgain)
        @high_filter = HighShelfFilter.create(soundinfo, freq: highfreq, q: 1.0/Math.sqrt(2.0), gain: highgain)
      end

      def process!(input)
        @low_filter.process!(input)
        @mid_filter.process!(input)
        @high_filter.process!(input)
      end

      def plot(width=500)
        data1 = @low_filter.plot_data(width)
        data2 = @mid_filter.plot_data(width)
        data3 = @high_filter.plot_data(width)

        data = {
          x: data1[:x],
          magnitude: [data1[:magnitude], data2[:magnitude], data3[:magnitude]].transpose.map {|a| a[0] + a[1] + a[2]},
          phase: [data1[:phase], data2[:phase], data3[:phase]].transpose.map {|a| a[0] + a[1] + a[2]},
        }

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
