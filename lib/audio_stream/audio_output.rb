module AudioStream
  class AudioOutput < AudioBus

    def initialize
      super()
    end

    def self.file(fname, soundinfo:)
      AudioOutputFile.new(fname, soundinfo: soundinfo)
    end

    def self.device(soundinfo:)
      AudioOutputDevice.default_device(soundinfo: soundinfo)
    end
  end
end
