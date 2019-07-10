module AudioStream
  class AudioBus < Rx::Subject
    def initialize
      super
      @observables = []
      @zip_observable = nil
      @detach = nil
    end

    def add(observable, gain:, pan:)
      if gain && gain!=1.0
        observable = observable.map(&Fx::AGain.new(level: gain).method(:process))
      end

      if pan && pan!=0.0
        observable = observable.map(&Fx::Panning.new(pan: pan).method(:process))
      end

      @observables << observable
      if @detach
        @detach.unsubscribe
      end

      @zip_observable = Rx::Observable.zip(*@observables).map{|a| a.inject(:+)}
      @detach = @zip_observable.subscribe(self)
    end
  end
end
