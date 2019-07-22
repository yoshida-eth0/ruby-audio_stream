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
      self
    end

    def disconnect
      if @connection
        @connection.kill
        @connection = nil
      end
      self
    end

    def stream
      @stream ||= Rx::Observable.create do |observer|
        each {|buf|
          sync.resume_wait
          observer.on_next(buf)
          sync.yield
        }
        sync.resume_wait
        sync.finish
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
  end
end
