module AudioStream

  module AudioInput
    include Enumerable

    attr_reader :connection

    def sync
      @sync ||= Sync.new
    end

    def connect
      @connection = Thread.start {
        stream.connect
      }
    end

    def stream
      @stream ||= Rx::Observable.create do |observer|
        each {|buf|
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
    end


    def self.file(fname, soundinfo:)
      AudioInputFile.new(fname, soundinfo: soundinfo)
    end

    def self.buffer(buf)
      AudioInputBuffer.new(buf)
    end

    def self.device(soundinfo:)
      AudioInputDevice.default_device(soundinfo: soundinfo)
    end

    def self.sin(hz, repeat, soundinfo:)
      AudioInputSin.new(hz, repeat, soundinfo: soundinfo)
    end
  end
end
