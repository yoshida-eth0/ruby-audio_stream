module AudioStream

  class AudioObservableFx
    include AudioObserver
    include AudioObservable

    def initialize(effector)
      @effector = effector
    end

    def on_next(input)
      if Fx::BangProcess===input
        @effector.process!(input)
        output = input
      else
        output = @effector.process(input)
      end
      notify_next(output)
    end

    def on_complete
      notify_complete
    end
  end
end
