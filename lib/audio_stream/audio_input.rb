module AudioStream

  class AudioInput
    def self.file(fname, window_size=1024)
      AudioInputFile.new(fname, window_size).stream
    end

    def self.buffer(buf)
      AudioInputBuffer.new([buf]).stream
    end

    def self.device(window_size=1024)
      AudioInputDevice.new(window_size).stream
    end

    def self.sin(hz, repeat, window_size=1024, soundinfo:)
      Rx::Observable.create do |observer|
        buf = RubyAudio::Buffer.float(window_size, soundinfo.channels)

        phase = hz.to_f / soundinfo.samplerate * 2 * Math::PI
        offset = 0

        repeat.times.each {|_|
          case soundinfo.channels
          when 1
            window_size.times.each {|i|
              buf[i] = Math.sin(phase * (i + offset))
            }
          when 2
            window_size.times.each {|i|
              val = Math.sin(phase * (i + offset))
              buf[i] = [val, val]
            }
          end
          offset += window_size
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
    end

    def self.empty(window_size=1024, soundinfo:)
      Rx::Observable.create do |observer|
        buf = RubyAudio::Buffer.float(window_size, soundinfo.channels)
        observer.on_next(buf)
        observer.on_completed
      end.publish
    end
  end
end
