module AudioStream
  class AudioInputBuffer < AudioInput

    def initialize(buffers)
      @buffers = buffers
    end

    def name
      "Buffer"
    end

    def each(&block)
      @buffers.each(&block)
    end
  end
end
