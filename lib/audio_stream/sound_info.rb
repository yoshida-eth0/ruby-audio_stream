module AudioStream
  class SoundInfo < RubyAudio::SoundInfo
    attr_accessor :window_size

    def clone
      SoundInfo.new(channels: channels, samplerate: samplerate, format: format, window_size: window_size)
    end
  end
end