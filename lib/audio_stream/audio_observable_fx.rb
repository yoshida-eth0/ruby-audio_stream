module AudioStream

  class AudioObservableFx
    include AudioObserver
    include AudioObservable

    def initialize(effector)
      @effector = effector
    end

    def on_next(input)
      output = @effector.process(input)
      notify_next(output)
    end

    def on_complete
      notify_complete
    end
  end
end
