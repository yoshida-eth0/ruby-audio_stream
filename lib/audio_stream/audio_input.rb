module AudioStream

  class AudioInput
    include Enumerable

    def stream
      Rx::Observable.create do |observer|
        each {|buf|
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
    end


    def self.file(fname, window_size=1024)
      AudioInputFile.new(fname, window_size)
    end

    def self.buffer(buf)
      AudioInputBuffer.new([buf])
    end

    def self.device(window_size=1024)
      AudioInputDevice.default_device(window_size)
    end

    def self.sin(hz, repeat, window_size=1024, soundinfo:)
      AudioInputSin.new(hz, repeat, window_size, soundinfo: soundinfo)
    end
  end
end
