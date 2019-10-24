module AudioStream
  class AudioOutputFile < AudioOutput
    def initialize(fname, soundinfo:)
      super()
      @fname = fname
      @soundinfo = soundinfo
    end

    def connect
      @sound = RubyAudio::Sound.open(@fname, "w", @soundinfo)
    end

    def disconnect
      if @sound && !@sound.closed?
        @sound.close
      end
    end

    def on_next(input)
      case @soundinfo.channels
      when 1
        input = input.mono
      when 2
        input = input.stereo
      end
      @sound.write(input.to_rabuffer)
    end

    def on_error(error)
      puts error
      puts error.backtrace.join("\n")
      @sound.close
    end

    def on_completed
      disconnect
    end
  end
end
