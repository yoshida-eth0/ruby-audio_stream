module AudioStream
  class Conductor
    def initialize(input:, output:)
      @inputs = Set[*[input].flatten.compact]
      @outputs = Set[*[output].flatten.compact]
    end

    def connect
      @outputs.map(&:connect)
      @inputs.map(&:connect)

      @sync_thread = Thread.start {
        catch :break do
          loop {
            @inputs.each {|t|
              t.sync.resume
            }

            @inputs.each {|t|
              stat = t.sync.yield_wait
              if stat==Sync::COMPLETED
                throw :break
              end
            }

            if @inputs.length==0
              throw :break
            end
          }
        end
      }
    end

    def join
      @sync_thread.join
      @inputs.map(&:disconnect)
      @outputs.map(&:disconnect)
    end
  end
end
