module AudioStream

  class AudioObservableLambda
    include AudioObserver
    include AudioObservable

    def initialize(&block)
      @block = block
    end

    def on_next(input)
      output = @block.call(input)
      notify_next(output)
    end

    def on_complete
      notify_complete
    end
  end
end
