module AudioStream
  class AudioObservableFxBus
    include AudioObserver
    include AudioObservable

    def initialize(effector)
      @effector = effector
      @mutex = Mutex.new
      @observable_keys = {}
      @notifications = {}
    end

    def connect_observable(key, observable)
      @mutex.synchronize {
        if !@effector.audio_input_keys.include?(key)
          raise Error.new("audio input key is not registed: %s => %s", @effector.class.name, key)
        end

        # delete
        @observable_keys.select {|obs, key1|
          key1==key
        }.each {|obs, key1|
          obs.delete_observer(self)
          @observable_keys.delete(obs)
        }

        # add
        @observable_keys[observable] = key
        observable.add_observer(self)
      }
    end

    def update(notification)
      do_notify = false
      is_completed = false
      next_inputs = nil

      @mutex.synchronize {
        @notifications[notification.caller_obj] = notification

        if @notifications.length==@observable_keys.length
          next_inputs = {}
          @notifications.each {|caller_obj, notification|
            key = @observable_keys[notification.caller_obj]
            case notification.stat
            when AudioNotification::STAT_NEXT
              next_inputs[key] = notification.input
            when AudioNotification::STAT_COMPLETE
              is_completed = true
            end
          }

          do_notify = true
          @notifications.clear
        end
      }

      if do_notify
        if !is_completed
          on_next(next_inputs)
        else
          on_complete
        end
      end
    end

    def on_next(inputs)
      output = @effector.process(inputs)
      notify_next(output)
    end

    def on_complete
      notify_complete
    end
  end
end
