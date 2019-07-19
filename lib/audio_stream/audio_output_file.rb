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
      @sound.close
    end

    def on_next(input)
      @sound.write(input)
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
