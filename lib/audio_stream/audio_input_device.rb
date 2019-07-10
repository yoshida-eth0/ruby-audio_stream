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

    def each(&block)
      Enumerator.new do |y|
        @inbuf = @dev.input_buffer(@soundinfo.window_size)
        @inbuf.start

        channels = @dev.input_stream.channels
        buf = Buffer.float(@soundinfo.window_size, channels)

        loop {
          sync.yield

          na = @inbuf.read(@soundinfo.window_size)
          @soundinfo.window_size.times {|i|
            buf[i] = na[(na.dim*i)...(na.dim*(i+1))].to_a.map{|s| s / 0x7FFF.to_f}
          }

          sync.resume_wait
          y << buf.clone
        }
        sync.finish
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
