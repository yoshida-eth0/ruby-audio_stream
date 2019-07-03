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

    def on_next(input)
      window_size = input.size
      channels = input.channels

      case @channels
      when 1
        input = StereoToMono.new.process(input)
      when 2
        input = MonoToStereo.new.process(input)
      end

      sint_a = input.to_a.flatten.map{|f| (f*0x7FFF).round}
      na = NArray.sint(@channels, window_size)
      na[0...sint_a.length] = sint_a
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
