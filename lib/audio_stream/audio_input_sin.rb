module AudioStream
  class AudioInputSin < AudioInput
    include AudioInputStream

    def initialize(hz, repeat, window_size=1024, soundinfo:)
      @hz = hz
      @repeat = repeat
      @window_size = window_size
      @soundinfo = soundinfo
    end

    def each(&block)
      Enumerator.new do |y|
        buf = RubyAudio::Buffer.float(@window_size, @soundinfo.channels)

        phase = @hz.to_f / @soundinfo.samplerate * 2 * Math::PI
        offset = 0

        @repeat.times.each {|_|
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
          y << buf.clone
        }
      end.each(&block)
    end
  end
end
