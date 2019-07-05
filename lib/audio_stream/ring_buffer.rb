module AudioStream
  class RingBuffer
    include Enumerable

    def initialize(*args, &block)
      @array = Array.new(*args, &block)
      @seek = 0
    end

    def each(&block)
      Enumerator.new do|y|
        start = @seek
        @array.size.times {|i|
          y << self[i]
        }
      end.each(&block)
    end

    def [](idx)
      @array[(idx+@seek) % @array.size]
    end

    def []=(idx, val)
      @array[(idx+@seek) % @array.size] = val
    end

    def current
      self[0]
    end

    def current=(val)
      self[0] = val
    end

    def rotate(step=1)
      @seek = (@seek + step) % @array.size
    end
  end
end
