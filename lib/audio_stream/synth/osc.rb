module AudioStream
  module Synth
    class Osc

      # @param shape [Synth::Shape] oscillator waveform shape
      # @param volume [Float] oscillator volume. mute=0.0 max=1.0
      # @param pan [Float] oscillator pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
      # @param tune_semis [Integer] oscillator pitch semitone
      # @param tune_cents [Integer] oscillator pitch cent
      # @param sym [nil] TODO not implemented
      # @param phase [Float] oscillator waveform shape start phase percent (0.0~1.0,nil) nil=random
      # @param sync [Integer] TODO not implemented
      # @param uni_num [Float] oscillator voicing number (1.0~16.0)
      # @param uni_detune [Float] oscillator voicing detune percent. 0.01=1cent 1.0=semitone (0.0~1.0)
      def initialize(shape: Shape::Sine, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, sym: 0, phase: nil, sync: 0, uni_num: 1.0, uni_detune: 0.0)
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
        case note_perform.synth.quality
        when Quality::HIGH
          high_generator(note_perform, &block)
        when Quality::LOW
          low_generator(note_perform, &block)
        end
      end

      def low_generator(note_perform, &block)
        Enumerator.new do |y|
          synth = note_perform.synth
          amp = synth.amp
          channels = synth.soundinfo.channels
          window_size = synth.soundinfo.window_size
          samplerate = synth.soundinfo.samplerate.to_f / window_size

          volume_mod = Param.amp_generator(note_perform, samplerate, @volume, amp.volume)
          pan_mod = Param.balance_generator(note_perform, samplerate, @pan, amp.pan)
          tune_semis_mod = Param.balance_generator(note_perform, samplerate, @tune_semis, amp.tune_semis)
          tune_cents_mod = Param.balance_generator(note_perform, samplerate, @tune_cents, amp.tune_cents)

          uni_num_mod = Param.balance_generator(note_perform, samplerate, @uni_num, amp.uni_num, center: 1.0)
          uni_detune_mod = Param.balance_generator(note_perform, samplerate, @uni_detune, amp.uni_detune)
          unison = Unison.new(note_perform, @shape, @phase)

          case channels
          when 1
            loop {
              buf = Buffer.float(window_size, channels)

              volume = volume_mod.next
              tune_semis = tune_semis_mod.next
              tune_cents = tune_cents_mod.next

              uni_num = uni_num_mod.next
              uni_detune = uni_detune_mod.next

              window_size.times.each {|i|
                val = unison.next(uni_num, uni_detune, volume, 0.0, tune_semis, tune_cents)
                buf[i] = (val[0] + val[1]) / 2.0
              }

              y << buf
            }
          when 2
            loop {
              buf = Buffer.float(window_size, channels)

              volume = volume_mod.next
              pan = pan_mod.next
              tune_semis = tune_semis_mod.next
              tune_cents = tune_cents_mod.next

              uni_num = uni_num_mod.next
              uni_detune = uni_detune_mod.next

              window_size.times.each {|i|
                buf[i] = unison.next(uni_num, uni_detune, volume, pan, tune_semis, tune_cents)
              }

              y << buf
            }
          end
        end.each(&block)
      end

      def high_generator(note_perform, &block)
        Enumerator.new do |y|
          synth = note_perform.synth
          amp = synth.amp
          channels = synth.soundinfo.channels
          window_size = synth.soundinfo.window_size
          samplerate = synth.soundinfo.samplerate

          volume_mod = Param.amp_generator(note_perform, samplerate, @volume, amp.volume)
          pan_mod = Param.balance_generator(note_perform, samplerate, @pan, amp.pan)
          tune_semis_mod = Param.balance_generator(note_perform, samplerate, @tune_semis, amp.tune_semis)
          tune_cents_mod = Param.balance_generator(note_perform, samplerate, @tune_cents, amp.tune_cents)

          uni_num_mod = Param.balance_generator(note_perform, samplerate, @uni_num, amp.uni_num, center: 1.0)
          uni_detune_mod = Param.balance_generator(note_perform, samplerate, @uni_detune, amp.uni_detune)
          unison = Unison.new(note_perform, @shape, @phase)

          case channels
          when 1
            loop {
              buf = Buffer.float(window_size, channels)

              window_size.times.each {|i|
                volume = volume_mod.next
                tune_semis = tune_semis_mod.next
                tune_cents = tune_cents_mod.next

                uni_num = uni_num_mod.next
                uni_detune = uni_detune_mod.next

                val = unison.next(uni_num, uni_detune, volume, 0.0, tune_semis, tune_cents)
                buf[i] = (val[0] + val[1]) / 2.0
              }

              y << buf
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
