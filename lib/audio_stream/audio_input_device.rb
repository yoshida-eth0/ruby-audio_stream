module AudioStream
  class AudioInputDevice < AudioInput

    attr_reader :dev

    def initialize(dev, window_size=1024)
      super()
      @dev = dev
      @window_size = window_size
    end

    def name
      @dev.name
    end

    def each(&block)
      Enumerator.new do |y|
        @inbuf = @dev.input_buffer(@window_size)
        @inbuf.start

        channels = @dev.input_stream.channels
        buf = Buffer.float(@window_size, channels)

        loop {
          @sync.yield

          na = @inbuf.read(@window_size)
          @window_size.times {|i|
            buf[i] = na[(na.dim*i)...(na.dim*(i+1))].to_a.map{|s| s / 0x7FFF.to_f}
          }

          @sync.resume_wait
          y << buf.clone
        }
        @sync.finish
      end.each(&block)
    end

    def self.default_device(window_size=1024)
      dev = CoreAudio.default_input_device
      new(dev, window_size)
    end

    def self.devices(window_size=1024)
      CoreAudio.devices
        .select{|dev|
          0<dev.input_stream.channels
        }
        .map {|dev|
          new(dev, window_size)
        }
    end
  end
end
