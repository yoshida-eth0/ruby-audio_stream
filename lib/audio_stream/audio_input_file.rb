module AudioStream
  class AudioInputFile < AudioInput

    def initialize(path, window_size=1024)
      @path = path
      @sound = RubyAudio::Sound.open(path)
      @window_size = window_size
      @sync = Sync.new
    end

    def name
      @name
    end

    def seek(frames, whence=IO::SEEK_SET)
      @sound.seek(frames, whence)
      self
    end

    def each(&block)
      Enumerator.new do |y|
        buf = Buffer.float(@window_size, @sound.info.channels)
        while @sound.read(buf)!=0
          buf.real_size = buf.size
          @sync.yield
          @sync.resume_wait
          y << buf.clone
        end
        @sync.finish
      end.each(&block)
    end
  end
end
