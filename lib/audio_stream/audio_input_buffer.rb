module AudioStream
  class AudioInputBuffer
    include AudioInput

    def initialize(buffers)
      @buffers = [buffers].flatten.compact
    end

    def connect
      self
    end

    def disconnect
      self
    end

    def connected?
      true
    end

    def each(&block)
      Enumerator.new do |y|
        @buffers.each {|buf|
          y << buf
        }
      end.each(&block)
    end
  end
end
