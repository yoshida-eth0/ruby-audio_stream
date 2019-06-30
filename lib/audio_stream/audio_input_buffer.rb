module AudioStream
  class AudioInputBuffer < AudioInput
    include AudioInputStream

    def initialize(buffers)
      @buffers = buffers
    end

    def each(&block)
      @buffers.each(&block)
    end
  end
end
