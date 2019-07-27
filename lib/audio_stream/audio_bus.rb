module AudioStream
  class AudioBus
    include AudioObserver
    include AudioObservable

    def initialize
      @mutex = Mutex.new
      @callers = Set[]
      @notifications = {}
    end

    def add(observable, gain:, pan:)
      if gain && gain!=1.0
        observable = observable.fx(Fx::AGain.new(level: gain))
      end

      if pan && pan!=0.0
        observable = observable.fx(Fx::Panning.new(pan: pan))
      end

      @mutex.synchronize {
        @callers << observable
        observable.add_observer(self)
      }
    end

    def update(notification)
      do_notify = false
      next_notifications = nil

      @mutex.synchronize {
        @notifications[notification.caller_obj] = notification

        if @callers.length==@notifications.length
          next_notifications = []
          @notifications.each {|caller_obj, notification|
            case notification.stat
            when AudioNotification::STAT_NEXT
              next_notifications << notification
            when AudioNotification::STAT_COMPLETE
              @callers.delete(caller_obj)
            end
          }

          do_notify = true
          @notifications.clear
        end
      }

      if do_notify
        if 0<next_notifications.length
          output = next_notifications.map(&:input).inject(:+)
          on_next(output)
        else
          on_complete
        end
      end
    end

    def on_next(input)
      notify_next(input)
    end

    def on_complete
      notify_complete
    end
  end
end
