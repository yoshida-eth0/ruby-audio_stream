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

    # @param effector [AudioStream::Fx::*] Effector
    # @param kwargs [Hash[String,AudioStream::AudioObservable]] Side chain bus
    def fx(effector, **kwargs)
      if Fx::MultiAudioInputtable===effector
        bus = AudioObservableFxBus.new(effector)
        bus.connect_observable(:main, self)
        kwargs.each {|key, observable|
          bus.connect_observable(key, observable)
        }
        bus
      else
        observer = AudioObservableFx.new(effector)
        add_observer(observer)
        observer
      end
    end

    def stereo
      observer = AudioObservableLambda.new {|input|
        input.stereo
      }
      add_observer(observer)
      observer
    end

    def mono
      observer = AudioObservableLambda.new {|input|
        input.mono
      }
      add_observer(observer)
      observer
    end

    # @param bus [AudioStream::AudioBus] Receive bus
    # @param gain [AudioStream::Decibel | Float] Amplification level (~0.0)
    # @param pan [Float] Panning (-1.0~1.0)
    def send_to(bus, gain: nil, pan: nil)
      bus.add(self, gain: gain, pan: pan)
      self
    end

    def subscribe(on_next:, on_complete: nil)
      observer = AudioObserverLambda.new(on_next: on_next, on_complete: on_complete)
      add_observer(observer)
      observer
    end

    def subscribe_on_next(&block)
      subscribe(on_next: block)
    end
  end
end
