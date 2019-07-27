module AudioStream

  module AudioObserver
    def update(notification)
      case notification.stat
      when AudioNotification::STAT_NEXT
        on_next(notification.input)
      when AudioNotification::STAT_COMPLETE
        on_complete
      end
    end
  end
end
