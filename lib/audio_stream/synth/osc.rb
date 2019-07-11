module AudioStream
  module Synth
    class Osc

      module Source
        Sine = ->(phase) { Math.sin(phase * 2 * Math::PI) }
        Sawtooth = ->(phase) { ((phase + 0.5) % 1) * 2 - 1 }
        Square = ->(phase) { 0.5<=((phase + 0.5) % 1) ? 1.0 : -1.0 }
        Triangle = ->(phase) {
          t = ((phase*4).floor % 4);
          t==0 ? (phase % 0.5)*4 :
          t==1 ? (2-(phase % 0.5)*4) :
          t==2 ? (-(phase % 0.5)*4) : (phase % 0.5)*4-2
        }
        WhiteNoise = ->(phase) { Random.rand(-1.0...1.0) }
      end

      def initialize(src: Source::Sine, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, sym: 0, phase: 0, sync: 0, uni_num: 1, uni_detune: 0, soundinfo:)
        @src = src

        @volume = Param.create(volume)
        @pan = Param.create(pan)
        @tune_semis = Param.create(tune_semis)
        @tune_cents = Param.create(tune_cents)

        @sym = Param.create(sym)
        @phase = Param.create(phase)
        @sync = Param.create(sync)

        @uni_num = Param.create(uni_num)
        @uni_detune = Param.create(uni_detune)

        @soundinfo = soundinfo
      end

      def generator(note_perform, &block)
        Enumerator.new do |y|
          buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)

          volume_mod = Param.generator(note_perform, note_perform.synth.volume, @volume)
          pan_mod = Param.generator(note_perform, note_perform.synth.pan, @pan)
          tune_semis_mod = Param.generator(note_perform, note_perform.synth.tune_semis, @tune_semis)
          tune_cents_mod = Param.generator(note_perform, note_perform.synth.tune_cents, @tune_cents)

          offset = 0

          loop {
            tune_semis = tune_semis_mod.next
            tune_cents = tune_cents_mod.next
            hz = note_perform.tune.hz(semis: tune_semis, cents: tune_cents)
            rate = hz / @soundinfo.samplerate

            case @soundinfo.channels
            when 1
              @soundinfo.window_size.times.each {|i|
                buf[i] = @src[rate * (i + offset)] * volume_mod.next
              }
            when 2
              @soundinfo.window_size.times.each {|i|
                val = @src[rate * (i + offset)] * volume_mod.next
                buf[i] = [val, val]
              }
            end
            offset += @soundinfo.window_size

            y << buf.clone
          }
        end.each(&block)
      end
    end
  end
end
