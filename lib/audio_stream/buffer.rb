module AudioStream
  class Buffer

    attr_reader :streams
    attr_reader :channels
    attr_reader :window_size

    def initialize(stream0, stream1=nil)
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
      self.class.merge(self, other)
    end

    def self.merge(*buffers)
      buffers = buffers.flatten

      if buffers.length==0
        raise Error, "argument is empty"
      elsif buffers.length==1
        return buffers.first.clone
      end

      buffers.each {|buf|
        unless Buffer===buf
          raise Error, "argument is not Buffer: #{buf}"
        end
        if buffers[0].window_size!=buf.window_size
          i = buffers.index(buf)
          raise Error, "Buffer.window_size is not match: buffers[0].window_size=#{buffers[0].window_size} buffers[#{i}].window_size=#{buf.window_size}"
        end
      }

      channels = buffers.map(&:channels).max
      window_size = buffers[0].window_size

      case channels
      when 1
        result0 = Array.new(window_size, 0.0)
        buffers.each {|buf|
          buf.streams[0].each_with_index {|f, i|
            result0[i] += f
          }
        }
        self.class.new(result0)
      when 2
        result0 = Array.new(window_size, 0.0)
        result1 = Array.new(window_size, 0.0)
        buffers.each {|buf|
          buf = buf.stereo
          src0 = buf.streams[0]
          src1 = buf.streams[1]
          window_size.times {|i|
            result0[i] += src0[i]
            result1[i] += src1[i]
          }
        }
        self.new(result0, result1)
      end
    end

    def plot
      xs = window_size.times.to_a
      traces = @streams.map {|stream|
        {x: xs, y: stream}
      }

      Plotly::Plot.new(data: traces)
    end

    def fft_plot(samplerate=44100, window=nil)
      window ||= HanningWindow.instance

      na = window.process(self).to_float_na
      fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length
      buf = Buffer.from_na(fft)

      xs = window_size.times.map{|i| i.to_f * samplerate / window_size}
      traces = buf.streams.map {|stream|
        {x: xs, y: stream}
      }

      Plotly::Plot.new(
        data: traces,
        xaxis: {title: 'Frequency (Hz)', type: 'log'}
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
        na[(0+offset)...(window_size+offset)] = @stream0
      when 2
        na[window_size.times.map{|i| i*2+offset}] = @stream0
        na[window_size.times.map{|i| i*2+1+offset}] = @stream1
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

    def self.create(window_size, channels)
      case channels
      when 1
        create_mono(window_size)
      when 2
        create_stereo(window_size)
      end
    end

    def self.create_mono(window_size)
      stream0 = Array.new(window_size, 0.0)
      new(stream0)
    end

    def self.create_stereo(window_size)
      stream0 = Array.new(window_size, 0.0)
      stream1 = Array.new(window_size, 0.0)
      new(stream0, stream1)
    end

    def self.from_na(na)
      channels = na.shape[0]
      window_size = na.size / channels

      case na.typecode
      when NArray::SINT
        max = 0x7FFF.to_f
      when NArray::FLOAT
        max = 1.0
      end

      case channels
      when 1
        stream0 = Array.new(window_size, 0.0)
        window_size.times {|i|
          stream0[i] = na[i].real / max
        }
        self.new(stream0)
      when 2
        stream0 = Array.new(window_size, 0.0)
        stream1 = Array.new(window_size, 0.0)
        window_size.times {|i|
          stream0[i] = na[i*2].real / max
          stream1[i] = na[(i*2)+1].real / max
        }
        self.new(stream0, stream1)
      end
    end

    def self.from_rabuffer(rabuf)
      channels = rabuf.channels
      window_size = rabuf.size

      case channels
      when 1
        stream0 = Array.new(window_size, 0.0)
        rabuf.each_with_index {|f, i|
          stream0[i] = f
        }
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
