module AudioStream
  class Sync
    NEXT = :next
    COMPLETED = :completed

    def initialize
      @resume_queue = SizedQueue.new(1)
      @yield_queue = SizedQueue.new(1)
    end 

    def resume
      @resume_queue.push true
    end 

    def yield
      @yield_queue.push NEXT
    end 

    def finish
      @yield_queue.push COMPLETED
    end

    def resume_wait
      @resume_queue.pop
    end 

    def yield_wait
      @yield_queue.pop
    end 
  end
end
