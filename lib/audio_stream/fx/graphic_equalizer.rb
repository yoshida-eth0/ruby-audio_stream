module AudioStream
  module Fx
    class GraphicEqualizer
      include BangProcess

      def initialize(soundinfo)
        @soundinfo = soundinfo
        @filters = []
      end

      def add(freq:, bandwidth: nil, gain:)
        bandwidth ||= 1.0/Math.sqrt(2.0)
        @filters << PeakingFilter.create(@soundinfo, freq: freq, bandwidth: bandwidth, gain: gain)
        self
      end

      def process!(input)
        @filters.each {|filter|
          filter.process!(input)
        }
      end

      def plot(width=500)
        data_arr = @filters.map{|filter| filter.plot_data(width)}

        data = {
          x: data_arr[0][:x],
          magnitude: data_arr.map{|d| d[:magnitude]}.transpose.map {|a| a.sum},
          phase: data_arr.map{|d| d[:phase]}.transpose.map {|a| a.sum},
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
