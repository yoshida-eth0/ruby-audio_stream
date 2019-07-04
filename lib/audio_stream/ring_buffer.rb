module AudioStream
  class RingBuffer < Array

    def initialize(*args, &block)
      super(*args, &block)
      @seek = 0
    end

    def ring(&block)
      Enumerator.new do|y|
        start = @seek
        self.size.times {|i|
          y << self[(start+i)%self.size]
        }
      end.each(&block)
    end

    def current
      self[@seek]
    end

    def current=(val)
      self[@seek] = val
    end

    def rotate
      @seek = (@seek + 1) % self.size
    end
  end
end
