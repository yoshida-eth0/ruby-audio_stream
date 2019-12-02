module AudioStream
  class Rate
    def initialize(sec: nil, sample: nil, freq: nil, sync: nil)
      @sec = sec
      @sample = sample
      @freq = freq
      @sync = sync
    end

    def sec(soundinfo)
      return @sec if @sec
      sample(soundinfo).to_f / soundinfo.samplerate
    end

    def frame(soundinfo)
      sample(soundinfo).to_f / soundinfo.window_size
    end

    def sample(soundinfo)
      if @sample
        return @sample
      end

      if @sec
        return @sec.to_f * soundinfo.samplerate
      end

      if @freq
        return soundinfo.samplerate.to_f / @freq
      end

      if @sync
        return @sync / 480.0 * soundinfo.sync_rate
      end
    end

    def freq(soundinfo)
      return @freq if @freq
      soundinfo.samplerate.to_f / sample(soundinfo)
    end

    def frame_phase(soundinfo)
      sample_phase(soundinfo) * soundinfo.window_size
    end

    def sample_phase(soundinfo)
      2.0 * Math::PI / sample(soundinfo)
    end

    def self.sec(v)
      new(sec: v)
    end

    def self.msec(v)
      new(sec: v*0.001)
    end

    def self.sample(v)
      new(sample: v)
    end

    def self.freq(v)
      new(freq: v)
    end

    def self.sync(v)
      new(sync: v)
    end


    SYNC_64     = sync(480 * 4 * 64)
    SYNC_32     = sync(480 * 4 * 32)
    SYNC_16     = sync(480 * 4 * 16)
    SYNC_8      = sync(480 * 4 * 8)
    SYNC_6      = sync(480 * 4 * 6)
    SYNC_4      = sync(480 * 4 * 4)
    SYNC_3      = sync(480 * 4 * 3)
    SYNC_2      = sync(480 * 4 * 2)
    SYNC_7_4    = sync(480 * 4 * 7 / 4)
    SYNC_6_4    = sync(480 * 4 * 6 / 4)
    SYNC_5_4    = sync(480 * 4 * 5 / 4)
    SYNC_1      = sync(480 * 4 * 1)
    SYNC_3_4    = sync(480 * 4 * 3 / 4)
    SYNC_1_2    = sync(480 * 4 * 1 / 2)
    SYNC_1_4D   = sync(480 * 4 * 1 / 4 * 3 / 2)
    SYNC_1_4    = sync(480 * 4 * 1 / 4)
    SYNC_1_4T   = sync(480 * 4 * 1 / 4 * 2 / 3)
    SYNC_1_8D   = sync(480 * 4 * 1 / 8 * 3 / 2)
    SYNC_1_8    = sync(480 * 4 * 1 / 8)
    SYNC_1_8T   = sync(480 * 4 * 1 / 8 * 2 / 3)
    SYNC_1_16D  = sync(480 * 4 * 1 / 16 * 3 / 2)
    SYNC_1_16   = sync(480 * 4 * 1 / 16)
    SYNC_1_16T  = sync(480 * 4 * 1 / 16 * 2 / 3)
    SYNC_1_32D  = sync(480 * 4 * 1 / 32 * 3 / 2)
    SYNC_1_32   = sync(480 * 4 * 1 / 32)
    SYNC_1_32T  = sync(480 * 4 * 1 / 32 * 2 / 3)
    SYNC_1_64D  = sync(480 * 4 * 1 / 64 * 3 / 2)
    SYNC_1_64   = sync(480 * 4 * 1 / 64)
    SYNC_1_64T  = sync(480 * 4 * 1 / 64 * 2 / 3)
    SYNC_1_128D = sync(480 * 4 * 1 / 128 * 3 / 2)
    SYNC_1_128  = sync(480 * 4 * 1 / 128)
    SYNC_1_128T = sync(480 * 4 * 1 / 128 * 2 / 3)
  end
end
