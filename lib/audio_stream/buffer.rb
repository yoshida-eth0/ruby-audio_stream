module AudioStream
  class Buffer

    attr_reader :streams
    attr_reader :channels
    attr_reader :window_size

    STREAM_NAMES = [
      'Left',
      'Right'
    ]
    COMPLEX_NAMES = [
      'Real',
      'Imag'
    ]

    def initialize(stream0, stream1=nil)
      if Array===stream0
        stream0 = Vdsp::DoubleArray.create(stream0)
      end
      if Array===stream1
        stream1 = Vdsp::DoubleArray.create(stream1)
      end

      @stream0 = stream0
      @stream1 = stream1

      if !stream1
        @streams = [stream0]
        @channels = 1
        @window_size = stream0.size
      else
        @streams = [stream0, stream1]
        @channels = 2
        @window_size = stream0.size

        if stream0.size!=stream1.size
          raise Error, "stream size is not match: stream0.size=#{stream0.size}, stream1.size=#{stream1.size}"
        end
      end
    end

    def stereo(deep_copy: false)
      case self.channels
      when 1
        if deep_copy
          self.class.new(@stream0.clone, @stream0.clone)
        else
          self.class.new(@stream0, @stream0)
        end
      when 2
        if deep_copy
          self.class.new(@stream0.clone, @stream1.clone)
        else
          self
        end
      end
    end

    def mono(deep_copy: false)
      case self.channels
      when 1
        if deep_copy
          self.class.new(@stream0.clone)
        else
          self
        end
      when 2
        mono_stream = window_size.times.map {|i|
          (@stream0[i] + @stream1[i]) * 0.5
        }
        self.class.new(mono_stream)
      end
    end

    def +(other)
      if self.window_size!=other.window_size
        raise Error, "Buffer.window_size is not match: self.window_size=#{self.window_size} other.window_size=#{other.window_size}"
      end

      channels = [self.channels, other.channels].max
      case channels
      when 1
        stream0 = self.streams[0] + other.streams[0]
        self.class.new(stream0)
      when 2
        st_self = self.stereo
        st_other = other.stereo

        stream0 = st_self.streams[0] + st_other.streams[0]
        stream1 = st_self.streams[1] + st_other.streams[1]
        self.class.new(stream0, stream1)
      end
    end

    def -(other)
      if self.window_size!=other.window_size
        raise Error, "Buffer.window_size is not match: self.window_size=#{self.window_size} other.window_size=#{other.window_size}"
      end

      channels = [self.channels, other.channels].max
      case channels
      when 1
        stream0 = self.streams[0] + other.streams[0]
        self.class.new(stream0)
      when 2
        st_self = self.stereo
        st_other = other.stereo

        stream0 = st_self.streams[0] - st_other.streams[0]
        stream1 = st_self.streams[1] - st_other.streams[1]
        self.class.new(stream0, stream1)
      end
    end

    def self.merge(buffers, average: false)
      buffers.each {|buf|
        unless Buffer===buf
          raise Error, "argument is not Buffer: #{buf}"
        end
      }

      if buffers.length==0
        raise Error, "argument is empty"
      elsif buffers.length==1
        return buffers[0]
      end

      dst = buffers.inject(:+)

      if average
        gain = AGain.new(level: Decibel.mag(1.0/buffers.length))
        dst = gain.process(dst)
      end

      dst
    end

    def plot
      xs = window_size.times.to_a
      traces = @streams.map.with_index {|stream,i|
        {x: xs, y: stream.to_a, name: STREAM_NAMES[i], xaxis: "x#{i+1}", yaxis: "y#{i+1}"}
      }

      layout = {
        grid: {rows: traces.length, columns: 1, pattern: :independent}
      }

      traces.each_with_index {|trace,i|
        max = [trace[:y].min.abs, trace[:y].max].max
        y_range = max<1.0 ? [-1.0, 1.0] : [-max, max]

        layout[:"yaxis#{i+1}"] = {side: 'left', title: 'Gain', range: y_range, showgrid: false}
      }

      layout[:"xaxis#{traces.length}"] = {title: 'Samples'}

      Plotly::Plot.new(
        data: traces,
        layout: layout
      )
    end

    def fft_plot(samplerate=44100, window=nil)
      window ||= Fx::HanningWindow.instance

      na = window.process(self).to_float_na
      fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length
      buf = Buffer.from_na(fft)

      xs = window_size.times.map{|i| i.to_f * samplerate / window_size}
      traces = buf.streams.map.with_index {|stream,i|
        {x: xs, y: stream.abs.to_a, name: COMPLEX_NAMES[i], xaxis: "x#{i+1}", yaxis: "y#{i+1}"}
      }

      layout = {
        xaxis1: {type: 'log'},
        xaxis2: {type: 'log'},
        grid: {rows: traces.length, columns: 1, pattern: :independent}
      }

      traces.each_with_index {|trace,i|
        max = trace[:y].max
        y_range = max<1.0 ? [0.0, 1.0] : [0.0, max]

        layout[:"yaxis#{i+1}"] = {side: 'left', title: 'Amplitude', range: y_range, showgrid: false}
      }

      layout[:"xaxis#{traces.length}"][:title] = 'Frequency (Hz)'

      Plotly::Plot.new(
        data: traces,
        layout: layout
      )
    end

    def to_float_na(dst=nil, offset=0)
      if dst
        if channels!=dst.shape[0]
          raise Error, "channels is not match: buffer.channels=#{channels} na.shape[0]=#{dst.shape[0]}"
        end
        if dst.typecode!=NArray::FLOAT
          raise Error, "typecode is not match: na.typecode=#{dst.typecode}"
        end
      end
      na = dst || NArray.float(channels, window_size)

      case channels
      when 1
        na[(0+offset)...(window_size+offset)] = @stream0.to_a
      when 2
        na[window_size.times.map{|i| i*2+offset}] = @stream0.to_a
        na[window_size.times.map{|i| i*2+1+offset}] = @stream1.to_a
      end

      na
    end

    def to_sint_na
      na = NArray.sint(channels, window_size)

      case channels
      when 1
        na[0...window_size] = @stream0.map {|f| (f * 0x7FFF).round}
      when 2
        na[window_size.times.map{|i| i*2}] = @stream0.map {|f| (f * 0x7FFF).round}
        na[window_size.times.map{|i| i*2+1}] = @stream1.map {|f| (f * 0x7FFF).round}
      end

      na
    end

    def to_rabuffer
      rabuf = RubyAudio::Buffer.float(window_size, channels)

      case channels
      when 1
        @stream0.each_with_index {|v, i|
          rabuf[i] = v
        }
      when 2
        stream0 = @stream0.to_a
        stream1 = @stream1.to_a
        window_size.times {|i|
          rabuf[i] = [stream0[i], stream1[i]]
        }
      end

      rabuf
    end

    def self.create(window_size, channels)
      case channels
      when 1
        create_mono(window_size)
      when 2
        create_stereo(window_size)
      end
    end

    def self.create_mono(window_size)
      stream0 = Vdsp::DoubleArray.new(window_size)
      new(stream0)
    end

    def self.create_stereo(window_size)
      stream0 = Vdsp::DoubleArray.new(window_size)
      stream1 = Vdsp::DoubleArray.new(window_size)
      new(stream0, stream1)
    end

    def self.from_na(na)
      channels = na.shape[0]
      window_size = na.size / channels

      is_complex = false
      case na.typecode
      when NArray::SINT
        max = 0x7FFF.to_f
      when NArray::FLOAT
        max = 1.0
      when NArray::DCOMPLEX
        max = 1.0
        is_complex = true
      end

      case channels
      when 1
        stream0 = []
        window_size.times {|i|
          stream0 << na[i].real / max
        }
        self.new(stream0)
      when 2
        stream0 = []
        stream1 = []
        if !is_complex
          window_size.times {|i|
            stream0 << na[i*2].real / max
            stream1 << na[(i*2)+1].real / max
          }
        else
          window_size.times {|i|
            stream0 << na[i*2].real / max
            stream1 << na[i*2].imag / max
          }
        end
        self.new(stream0, stream1)
      end
    end

    def self.from_rabuffer(rabuf)
      channels = rabuf.channels
      window_size = rabuf.size

      case channels
      when 1
        stream0 = rabuf.to_a
        while stream0.size<window_size
          stream0 << 0.0
        end
        self.new(stream0)
      when 2
        stream0 = Array.new(window_size, 0.0)
        stream1 = Array.new(window_size, 0.0)
        rabuf.each_with_index {|fa, i|
          stream0[i] = fa[0]
          stream1[i] = fa[1]
        }
        self.new(stream0, stream1)
      end
    end
  end
end
