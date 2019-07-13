module AudioStream
  module Synth
    class ShapePos
      def initialize(phase: 0.0, sync: nil)
        @init_phase = phase
        @sync = sync

        @offset = 0
        @phase = 0.0
      end

      def next(delta)
        @offset += 1

        if @offset==1
          if @init_phase
            @phase = @init_phase + delta
          else
            @phase = Random.rand + delta
          end
        # TODO: sync
        #elsif @sync && @sync<@offset
        #  @offset = 0
        #  @phase = @init_phase
        else
          @phase += delta
        end
      end
    end
  end
end
