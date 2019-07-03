module AudioStream
  class AudioInputFile < AudioInput
    include AudioInputStream

    def initialize(fname, window_size=1024)
      @sound = RubyAudio::Sound.open(fname)
      @window_size = window_size
    end

    def each(&block)
      Enumerator.new do |y|
        buf = Buffer.float(@window_size, @sound.info.channels)
        while @sound.read(buf)!=0
          y << buf.clone
        end
      end.each(&block)
    end
  end
end
