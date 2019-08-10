module AudioStream
  class AudioInputDevice
    include AudioInput

    attr_reader :dev

    def initialize(dev, soundinfo:)
      @dev = dev
      @soundinfo = soundinfo
    end

    def name
      @dev.name
    end

    def connect
      if !connected?
        @inbuf = @dev.input_buffer(@soundinfo.window_size)
        @inbuf.start
      end
      self
    end

    def disconnect
      if connected?
        @inbuf.stop
        @inbuf = nil
      end
      super
    end

    def connected?
      !!@inbuf
    end

    def each(&block)
      Enumerator.new do |y|
        if !connected?
          raise Error, "Device is not connected. You need to exec #{self.class.name}.connect: #{name}"
        end

        loop {
          na = @inbuf.read(@soundinfo.window_size)
          y << Buffer.from_na(na)
        }
      end.each(&block)
    end

    def self.default_device(soundinfo:)
      dev = CoreAudio.default_input_device
      new(dev, soundinfo: soundinfo)
    end

    def self.devices(soundinfo:)
      CoreAudio.devices
        .select{|dev|
          0<dev.input_stream.channels
        }
        .map {|dev|
          new(dev, soundinfo: soundinfo)
        }
    end
  end
end
