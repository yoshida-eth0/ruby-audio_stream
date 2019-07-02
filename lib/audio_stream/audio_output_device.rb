module AudioStream
  class AudioOutputDevice < AudioOutput
    attr_reader :dev

    def initialize(dev, window_size=1024)
      super()
      @dev = dev
      @channels = dev.output_stream.channels
      @buf = dev.output_buffer(window_size)
    end

    def connect
      @buf.start
    end

    def on_next(a)
      a = [a].flatten
      window_size = a.map(&:size).max
      channels = a.first&.channels

      case @channels
      when 1
        a = a.map {|x| StereoToMono.new.process(x)}
      when 2
        a = a.map {|x| MonoToStereo.new.process(x)}
      end

      na = NArray.sint(@channels, window_size)
      a.each {|x|
        xa = x.to_a.flatten.map{|f| (f*0x7FFF).round}
        na2 = NArray.sint(@channels, window_size)
        na2[0...xa.length] = xa
        na += na2
      }
      @buf << na
    end

    def on_error(error)
      puts error
      puts error.backtrace.join("\n")
    end

    def on_completed
    end

    def self.default_device(window_size=1024)
      dev = CoreAudio.default_output_device
      new(dev, window_size)
    end

    def self.devices(window_size=1024)
      CoreAudio.devices
        .select{|dev|
          0<dev.output_stream.channels
        }
        .map {|dev|
          new(dev, window_size)
        }
    end
  end
end
