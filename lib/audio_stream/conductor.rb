module AudioStream
  class Conductor
    def initialize(input:, output:)
      @inputs = Set[*[input].flatten.compact]
      @outputs = Set[*[output].flatten.compact]
    end

    def connect
      @outputs.map(&:connect)
      @input_connections = @inputs.map(&:connect)

      @sync_thread = Thread.start {
        loop {
          @inputs.each {|t|
            stat = t.sync.yield_wait
            if stat==Sync::COMPLETED
              @inputs.delete(t)
            end
          }

          if @inputs.length==0
            break
          end

          @inputs.each {|t|
            t.sync.resume
          }
        }
      }
    end

    def join
      @outputs.map(&:join)
      @input_connections.map(&:join)
      @sync_thread.join
    end
  end
end
