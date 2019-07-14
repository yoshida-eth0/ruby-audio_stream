module AudioStream
  class AudioInputFile
    include AudioInput

    def initialize(path, soundinfo:)
      @path = path
      @sound = RubyAudio::Sound.open(path)
      @soundinfo = soundinfo
    end

    def name
      @path
    end

    def seek(frames, whence=IO::SEEK_SET)
      @sound.seek(frames, whence)
      self
    end

    def each(&block)
      Enumerator.new do |y|
        buf = Buffer.float(@soundinfo.window_size, @sound.info.channels)
        while @sound.read(buf)!=0
          buf.real_size = buf.size
          y << buf.clone
        end
      end.each(&block)
    end
  end
end
