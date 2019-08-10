module AudioStream
  class AudioOutputDevice < AudioOutput
    attr_reader :dev

    def initialize(dev, soundinfo:)
      super()
      @dev = dev
      @channels = dev.output_stream.channels
      @buf = dev.output_buffer(soundinfo.window_size)
    end

    def connect
      @buf.start
    end

    def disconnect
      @buf.stop
    end

    def on_next(input)
      window_size = input.window_size
      channels = input.channels

      case @channels
      when 1
        input = input.mono
      when 2
        input = input.stereo
      end

      @buf << input.to_sint_na
    end

    def on_error(error)
      puts error
      puts error.backtrace.join("\n")
    end

    def on_completed
      disconnect
    end

    def self.default_device(soundinfo:)
      dev = CoreAudio.default_output_device({nominal_rate: soundinfo.samplerate})
      new(dev, soundinfo: soundinfo)
    end

    def self.devices(soundinfo:)
      CoreAudio.devices({nominal_rate: soundinfo.samplerate})
        .select{|dev|
          0<dev.output_stream.channels
        }
        .map {|dev|
          new(dev, soundinfo: soundinfo)
        }
    end
  end
end
