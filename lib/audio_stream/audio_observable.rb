require 'observer'

module AudioStream

  module AudioObservable
    include Observable

    def notify_next(input)
      changed
      notify_observers(AudioNotification.new(AudioNotification::STAT_NEXT, input, self))
    end

    def notify_complete
      changed
      notify_observers(AudioNotification.new(AudioNotification::STAT_COMPLETE, nil, self))
    end

    def fx(effector)
      observer = AudioObservableFx.new(effector)
      add_observer(observer)
      observer
    end

    def send_to(bus, gain: nil, pan: nil)
      bus.add(self, gain: gain, pan: pan)
      self
    end
  end
end
