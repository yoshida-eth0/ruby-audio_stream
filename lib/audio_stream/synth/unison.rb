module AudioStream
  module Synth
    class Unison
      UNI_NUM_MAX = 16

      def initialize(note_perform, shape, phase)
        @note_perform = note_perform
        @shape = shape
        @poss = UNI_NUM_MAX.times.map {|i|
          ShapePos.new(phase: phase.value)
        }

        synth = note_perform.synth
        @samplerate = synth.soundinfo.samplerate
      end

      def next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)
        if uni_num<1.0
          uni_num = 1.0
        elsif UNI_NUM_MAX<uni_num
          uni_num = UNI_NUM_MAX
        end

        val_l = 0.0
        val_r = 0.0

        uni_num.ceil.times {|i|
          pos = @poss[i]

          uni_volume = 1.0
          if uni_num<i
            uni_volume = uni_num % 1.0
          end

          sign = i.even? ? 1 : -1
          detune_cents = sign * (i/2) * uni_detune * 100
          diff_pan = sign * (i/2) * uni_detune

          panh = Utils.panning(pan + diff_pan)
          l_gain = panh[:l_gain]
          r_gain = panh[:r_gain]

          hz = @note_perform.tune.hz(semis: tune_semis, cents: tune_cents + detune_cents)
          delta = hz / @samplerate

          val = @shape[pos.next(delta)] * uni_volume
          val_l += val * l_gain
          val_r += val * r_gain
        }

        [val_l * volume / uni_num, val_r * volume / uni_num]
      end
    end
  end
end
