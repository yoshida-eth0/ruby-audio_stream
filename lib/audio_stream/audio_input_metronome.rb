module AudioStream
  class AudioInputMetronome
    include AudioInput

    def initialize(bpm, repeat=nil, soundinfo:)
      @bpm = bpm
      @repeat = repeat
      @soundinfo = soundinfo
    end

    def name
      "Metronome"
    end

    def each(&block)
      Enumerator.new do |y|
        period = @soundinfo.samplerate / @soundinfo.window_size * 60.0 / @bpm
        count = 0

        empty_buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)
        phase = 440.0 / @soundinfo.samplerate * 2 * Math::PI
        offset = 0

        Range.new(0, @repeat).each {|_|
          if count<1
            buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)
            case @soundinfo.channels
            when 1
              @soundinfo.window_size.times.each {|i|
                buf[i] = Math.sin(phase * (i + offset))
              }
            when 2
              @soundinfo.window_size.times.each {|i|
                val = Math.sin(phase * (i + offset))
                buf[i] = [val, val]
              }
            end
            offset += @soundinfo.window_size

            y << buf
          else
            y << empty_buf.clone
          end
          count = (count + 1) % period
        }
      end.each(&block)
    end
  end
end
