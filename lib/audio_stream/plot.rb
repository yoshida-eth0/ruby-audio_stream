module AudioStream
  class Plot
    def initialize(input, soundinfo=nil)
      @input = input
      if soundinfo
        @samplerate = soundinfo.samplerate.to_f
      end
    end

    def wave
      buf_to_plot(@input)
    end

    def fft(window=nil)
      window ||= HanningWindow.instance

      na = window.process(@input).to_na
      fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

      buf = Buffer.from_na(fft)
      buf_to_plot(buf, true)
    end

    def buf_to_plot(input, x_hz=false)
      window_size = input.size
      channels = input.channels
      outputs = []

      case channels
      when 1
        outputs << input.to_a
      when 2
        outputs << output_l = []
        outputs << output_r = []
        window_size.times {|i|
          output_l << input[i][0]
          output_r << input[i][1]
        }
      end

      window_arr = window_size.times.to_a
      if x_hz && @samplerate
        window_arr.map!{|i| i * @samplerate / window_size}
      end

      traces = outputs.map {|output|
        {x: window_arr, y: output}
      }

      Plotly::Plot.new(data: traces)
    end
  end
end
