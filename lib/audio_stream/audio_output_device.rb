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
      dev = CoreAudio.default_output_device
      is_supported_sample_rate = dev.available_sample_rate.any? {|min,max|
        min<=soundinfo.samplerate && soundinfo.samplerate<=max
      }
      if !is_supported_sample_rate
        raise Error, "Unsupported sample rate: samplerate=#{soundinfo.samplerate}, device=#{dev.name}, available_sample_rate=#{dev.available_sample_rate}"
      end

      dev = CoreAudio.default_output_device({nominal_rate: soundinfo.samplerate})
      new(dev, soundinfo: soundinfo)
    end

    def self.devices(soundinfo:)
      self.core_devices
        .select {|dev|
          dev.available_sample_rate.any? {|min,max|
            min<=soundinfo.samplerate && soundinfo.samplerate<=max
          }
        }
        .map {|dev|
          new(dev, soundinfo: soundinfo)
        }
    end

    def self.core_devices
      CoreAudio.devices
        .select {|dev|
          0<dev.output_stream.channels
        }
    end
  end
end
