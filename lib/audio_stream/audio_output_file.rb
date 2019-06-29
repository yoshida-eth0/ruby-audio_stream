module AudioStream
  class AudioOutputFile < AudioOutput
    def initialize(fname, soundinfo)
      super()
      @sound = RubyAudio::Sound.open(fname, "w", soundinfo)
    end

    def on_next(a)
      a = [a].flatten
      window_size = a.map(&:size).max
      channels = a.first&.channels
      buf = RubyAudio::Buffer.float(window_size, channels)

      case channels
      when 1
        a.each {|x|
          x.size.times.each {|i|
            if buf[i]
              buf[i] += x[i]
            else
              buf[i] = x[i]
            end
          }
        }
      when 2
        a.each {|x|
          x.size.times.each {|i|
            if buf[i]
              buf[i] = buf[i].zip(x[i]).map {|a| a[0] + a[1]}
            else
              buf[i] = x[i]
            end
          }
        }
      end
      @sound.write(buf)
    end

    def on_error(error)
      puts error
      puts error.backtrace.join("\n")
      @sound.close
    end

    def on_completed
      @sound.close
    end
  end
end
