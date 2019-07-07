module AudioStream
  class AudioInputSin < AudioInput

    def initialize(hz, repeat=nil, window_size=1024, soundinfo:)
      super()
      @hz = hz
      @repeat = repeat
      @window_size = window_size
      @soundinfo = soundinfo
    end

    def name
      "SinWave"
    end

    def each(&block)
      Enumerator.new do |y|
        buf = Buffer.float(@window_size, @soundinfo.channels)

        phase = @hz.to_f / @soundinfo.samplerate * 2 * Math::PI
        offset = 0

        Range.new(0, @repeat).each {|_|
          @sync.yield

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
          y << buf.clone
        }
        @sync.finish
      end.each(&block)
    end
  end
end
