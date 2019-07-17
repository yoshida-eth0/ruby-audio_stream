module AudioStream
  class AudioInputBuffer
    include AudioInput

    def initialize(buffers)
      @buffers = [buffers].flatten.compact
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
