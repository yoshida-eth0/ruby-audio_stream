module AudioStream
  module Synth
    class ShapePos
      def initialize(delay: 0.0, phase: 0.0, attack: 0.0, attack_curve: nil, sync: nil)
        @delay = delay
        @init_phase = phase
        @attack = attack
        @attack_curve = attack_curve
        @sync = sync

        @offset = 0
        @phase = 0.0
      end

      def next(delta)
        @offset += 1

        # TODO: attack

        if @offset<@delay
          0.0
        elsif @delay==@offset-1
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
