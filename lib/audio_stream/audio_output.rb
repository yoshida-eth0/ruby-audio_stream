module AudioStream
  class AudioOutput < AudioBus
    def self.file(fname, soundinfo)
      AudioOutputFile.new(fname, soundinfo)
    end

    def self.device(window_size=1024)
      AudioOutputDevice.default_device(window_size)
    end
  end
end
