module AudioStream
  module Synth
    module Modulation
      class Lfo

        # @param shape [Synth::Shape]
        # @param delay [Float] delay sec (0.0~)
        # @param attack [Float] attack sec (0.0~)
        # @param attack_curve [Synth::Curve]
        # @param phase [Float] phase percent (0.0~1.0)
        # @param rate [Float] wave freq (0.0~)
        def initialize(shape: Shape::Sine, delay: 0.0, attack: 0.0, attack_curve: Curve::EaseOut, phase: 0.0, rate: 3.5)
          @shape = shape
          @delay = delay
          @attack = attack
          @attack_curve = attack_curve
          @phase = phase
          @rate = rate
        end

        def balance_generator(note_perform, sustain: true, &block)
          Enumerator.new do |y|
            samplerate = note_perform.synth.soundinfo.samplerate

            # TODO: delay, attack, attack_curve, phase

            pos = ShapePos.new(delay: @delay * samplerate, attack: @attack * samplerate, attack_curve: @attack_curve, phase: @phase)

            loop {
              rate = @rate / samplerate
              val = @shape[pos.next(rate)]
              y << val
            }
          end.each(&block)
        end
      end
    end
  end
end
