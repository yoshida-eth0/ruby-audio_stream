module AudioStream

  module AudioInput
    include Enumerable
    include AudioObservable

    attr_reader :connection

    def sync
      @sync ||= Sync.new
    end

    def publish
      @connection = Thread.start {
        each {|input|
          sync.resume_wait
          notify_next(input)
          sync.yield
        }
        sync.resume_wait
        notify_complete
        sync.finish
      }
      self
    end

    def connect
      nil
    end

    def disconnect
      if @connection
        @connection.kill
        @connection = nil
      end
      self
    end

    def connected?
      nil
    end

    def published?
      !!@connection
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
