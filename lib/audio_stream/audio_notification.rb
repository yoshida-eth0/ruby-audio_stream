module AudioStream

  class AudioNotification
    STAT_NEXT = :next
    STAT_COMPLETE = :complete

    attr_reader :stat
    attr_reader :input
    attr_reader :caller_obj

    def initialize(stat, input, caller_obj)
      @stat = stat
      @input = input
      @caller_obj = caller_obj
    end
  end
end
