module AudioStream
  module Synth
    class Osc

      # @param shape [Synth::Shape]
      # @param volume [Float] mute=0.0 max=1.0
      # @param pan [Float] left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
      # @param tune_semis [Integer] pitch semitone
      # @param tune_cents [Integer] pitch cent
      # @param sym [nil] TODO not implemented
      # @param phase [Float] start phase percent (0.0~1.0,nil) nil=random
      # @param sync [Integer] TODO not implemented
      # @param uni_num [Float] voicing number (1.0~16.0)
      # @param uni_detune [Float] voicing detune percent (0.0~1.0)
      def initialize(shape: Shape::Sine, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, sym: 0, phase: nil, sync: 0, uni_num: 1.0, uni_detune: 0.3)
        @shape = shape

        @volume = Param.create(volume)
        @pan = Param.create(pan)
        @tune_semis = Param.create(tune_semis)
        @tune_cents = Param.create(tune_cents)

        @sym = Param.create(sym)
        @phase = Param.create(phase)
        @sync = Param.create(sync)

        @uni_num = Param.create(uni_num)
        @uni_detune = Param.create(uni_detune)
      end

      def generator(note_perform, &block)
        Enumerator.new do |y|
          synth = note_perform.synth
          channels = synth.soundinfo.channels
          samplerate = synth.soundinfo.samplerate
          window_size = synth.soundinfo.window_size

          volume_mod = Param.amp_generator(note_perform, synth.volume, @volume)
          pan_mod = Param.balance_generator(note_perform, synth.pan, @pan)
          tune_semis_mod = Param.balance_generator(note_perform, synth.tune_semis, @tune_semis)
          tune_cents_mod = Param.balance_generator(note_perform, synth.tune_cents, @tune_cents)

          uni_num_mod = Param.balance_generator(note_perform, @uni_num)
          uni_detune_mod = Param.balance_generator(note_perform, @uni_detune)
          unison = Unison.new(note_perform, @shape, @phase)

          case channels
          when 1
            # TODO
            window_size.times.each {|i|
            }
          when 2
            loop {
              buf = Buffer.float(window_size, channels)

              window_size.times.each {|i|
                volume = volume_mod.next
                pan = pan_mod.next
                tune_semis = tune_semis_mod.next
                tune_cents = tune_cents_mod.next

                uni_num = uni_num_mod.next
                uni_detune = uni_detune_mod.next

                buf[i] = unison.next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)
              }

              y << buf
            }
          end
        end.each(&block)
      end
    end
  end
end
