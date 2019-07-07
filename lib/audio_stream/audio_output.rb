module AudioStream
  class AudioOutput < AudioBus

    def initialize
      super()
      @sync = Sync.new
    end

    def self.file(fname, soundinfo)
      AudioOutputFile.new(fname, soundinfo)
    end

    def self.device(window_size=1024)
      AudioOutputDevice.default_device(window_size)
    end
  end
end
