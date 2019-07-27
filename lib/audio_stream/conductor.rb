module AudioStream
  class Conductor
    def initialize(input:, output:)
      @inputs = Set[*[input].flatten.compact]
      @outputs = Set[*[output].flatten.compact]
    end

    def connect
      @outputs.map(&:connect)
      @inputs.map(&:connect)
      @inputs.map(&:publish)

      @sync_thread = Thread.start {
        catch :break do
          loop {
            @inputs.each {|input|
              input.sync.resume
            }

            @inputs.each {|input|
              stat = input.sync.yield_wait
              if stat==Sync::COMPLETED
                @inputs.delete(input)
                #throw :break
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
