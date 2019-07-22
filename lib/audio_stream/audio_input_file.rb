module AudioStream
  class AudioInputFile
    include AudioInput

    attr_reader :path

    def initialize(path, soundinfo:)
      @path = path
      @soundinfo = soundinfo
    end

    def connect
      @sound = RubyAudio::Sound.open(@path)
      super
    end

    def disconnect
      if @sound && !@sound.closed?
        @sound.close
      end
      super
    end

    def seek(frames, whence=IO::SEEK_SET)
      @sound.seek(frames, whence)
      self
    end

    def each(&block)
      Enumerator.new do |y|
        if !@sound || @sound.closed?
          raise Error, "File is not opened. You need to exec #{self.class.name}.connect: #{@path}"
        end

        buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)
        while @sound.read(buf)!=0
          buf.real_size = buf.size
          y << buf.clone
        end
      end.each(&block)
    end
  end
end
