module AudioStream
  class AudioInputMetronome < AudioInput

    def initialize(bpm, repeat=nil, window_size=1024, soundinfo:)
      super()
      @bpm = bpm
      @repeat = repeat
      @window_size = window_size
      @soundinfo = soundinfo
    end

    def name
      "Metronome"
    end

    def each(&block)
      Enumerator.new do |y|
        period = @soundinfo.samplerate / @window_size * 60.0 / @bpm
        count = 0

        empty_buf = Buffer.float(@window_size, @soundinfo.channels)
        phase = 440.0 / @soundinfo.samplerate * 2 * Math::PI
        offset = 0

        Range.new(0, @repeat).each {|_|
          @sync.yield

          if count<1
            buf = Buffer.float(@window_size, @soundinfo.channels)
            case @soundinfo.channels
            when 1
              @window_size.times.each {|i|
                buf[i] = Math.sin(phase * (i + offset))
              }
            when 2
              @window_size.times.each {|i|
                val = Math.sin(phase * (i + offset))
                buf[i] = [val, val]
              }
            end
            offset += @window_size

            @sync.resume_wait
            y << buf
          else
            @sync.resume_wait
            y << empty_buf.clone
          end
          count = (count + 1) % period
        }
        @sync.finish
      end.each(&block)
    end
  end
end
