module AudioStream
  module Synth
    module Processor
      class Low
        def generator(osc, note, &block)
          Enumerator.new do |y|
            synth = note.synth
            amp = synth.amp
            channels = synth.soundinfo.channels
            window_size = synth.soundinfo.window_size
            samplerate = synth.soundinfo.samplerate.to_f / window_size

            volume_mod = Param.amp_generator(note, samplerate, osc.volume, amp.volume)
            pan_mod = Param.balance_generator(note, samplerate, osc.pan, amp.pan)
            tune_semis_mod = Param.balance_generator(note, samplerate, osc.tune_semis, amp.tune_semis)
            tune_cents_mod = Param.balance_generator(note, samplerate, osc.tune_cents, amp.tune_cents)

            uni_num_mod = Param.balance_generator(note, samplerate, osc.uni_num, amp.uni_num, center: 1.0)
            uni_detune_mod = Param.balance_generator(note, samplerate, osc.uni_detune, amp.uni_detune)
            unison = Unison.new(note, osc.shape, osc.phase)

            case channels
            when 1
              loop {
                buf = Buffer.float(window_size, channels)

                volume = volume_mod.next
                tune_semis = tune_semis_mod.next + synth.pitch_bend
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
                tune_semis = tune_semis_mod.next + synth.pitch_bend
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
      end
    end
  end
end
