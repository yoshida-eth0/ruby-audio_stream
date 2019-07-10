module AudioStream
  class AudioInputSin
    include AudioInput

    def initialize(hz, repeat=nil, soundinfo:)
      @hz = hz
      @repeat = repeat
      @soundinfo = soundinfo
    end

    def name
      "SinWave"
    end

    def each(&block)
      Enumerator.new do |y|
        buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)

        phase = @hz.to_f / @soundinfo.samplerate * 2 * Math::PI
        offset = 0

        Range.new(0, @repeat).each {|_|
          sync.yield

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

          sync.resume_wait
          y << buf.clone
        }
        sync.finish
      end.each(&block)
    end
  end
end
