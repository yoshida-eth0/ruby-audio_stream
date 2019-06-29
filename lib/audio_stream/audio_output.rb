module AudioStream
  class AudioOutput < AudioBus
    def self.file(fname, soundinfo)
      AudioOutputFile.new(fname, soundinfo)
    end

    def self.device
      AudioOutputDevice.new
    end
  end
end
