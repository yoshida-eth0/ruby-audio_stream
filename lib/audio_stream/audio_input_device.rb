module AudioStream
  class AudioInputDevice < AudioInput
    include AudioInputStream

    def initialize(window_size=1024)
      @window_size = window_size
      @dev = CoreAudio.default_input_device
      @inbuf = @dev.input_buffer(window_size)
    end

    def each(&block)
      Enumerator.new do |y|
        @inbuf.start

        channels = @dev.input_stream.channels
        buf = RubyAudio::Buffer.float(@window_size, channels)

        loop {
          na = @inbuf.read(@window_size)
          @window_size.times {|i|
            buf[i] = na[(na.dim*i)...(na.dim*(i+1))].to_a.map{|s| s / 0x7FFF.to_f}
          }
          y << buf.clone
        }
      end.each(&block)
    end
  end
end
