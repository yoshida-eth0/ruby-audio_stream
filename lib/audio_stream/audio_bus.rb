class AudioBus < Rx::Subject
  def initialize
    super
    @observables = []
    @zip_observable = nil
    @detach = nil
  end

  def add(observable)
    @observables << observable
    if @detach
      @detach.unsubscribe
    end

    @zip_observable = Rx::Observable.zip(*@observables).map{|a| a.inject(:+)}
    @detach = @zip_observable.subscribe(self)
  end
end
