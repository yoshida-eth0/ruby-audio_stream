module AudioStream

  class AudioInput
    def self.file(fname, window_size=1024)
      Rx::Observable.create do |observer|
        sound = RubyAudio::Sound.open(fname)
        buf = RubyAudio::Buffer.float(window_size, sound.info.channels)
        while sound.read(buf)!=0
          observer.on_next(buf)
        end
        observer.on_completed
      end.publish
    end

    def self.buffer(buf)
      Rx::Observable.create do |observer|
        observer.on_next(buf)
        observer.on_completed
      end.publish
    end

    def self.device(window_size=1024)
      Rx::Observable.create do |observer|
        dev = CoreAudio.default_input_device
        inbuf = dev.input_buffer(window_size)
        inbuf.start

        channels = dev.input_stream.channels
        buf = RubyAudio::Buffer.float(window_size, channels)

        loop {
          na = inbuf.read(window_size)
          window_size.times {|i|
            buf[i] = na[(na.dim*i)...(na.dim*(i+1))].to_a.map{|s| s / 0x7FFF.to_f}
          }
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
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
