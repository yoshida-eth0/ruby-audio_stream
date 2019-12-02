module AudioStream
  class SoundInfo < RubyAudio::SoundInfo
    attr_accessor :window_size
    attr_reader :bpm
    attr_reader :bps

    def framerate
      self.samplerate.to_f / self.window_size
    end

    def bpm=(bpm)
      @bpm = bpm.to_f
      @bps = @bpm / 60.0
    end

    def sync_rate
      self.samplerate.to_f / self.bps
    end

    def clone
      SoundInfo.new(channels: channels, samplerate: samplerate, format: format, window_size: window_size, bpm: bpm)
    end
  end
end
