module AudioStream

  class AudioObserverLambda
    include AudioObserver

    def initialize(on_next:, on_complete:)
      @on_next = on_next || ->(input){}
      @on_complete = on_complete || ->(){}
    end

    def on_next(input)
      @on_next[input]
    end

    def on_complete
      @on_complete[]
    end
  end
end
