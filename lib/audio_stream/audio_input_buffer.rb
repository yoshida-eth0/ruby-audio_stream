module AudioStream
  class AudioInputBuffer < AudioInput
    include AudioInputStream

    def initialize(buffers)
      @buffers = buffers
    end

    def each(&block)
      @buffers.each(&block)
    end

    def stream
      Rx::Observable.create do |observer|
        each {|buf|
          observer.on_next(buf)
        }
        observer.on_completed
      end.publish
    end
  end
end
