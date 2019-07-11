module AudioStream
  module Synth
    module Modulation
      class Adsr

        module Curve
          Straight = ->(x) { x }
          EaseIn = ->(x) { x ** 2 }
          EaseOut = ->(x) { x * (2 - x) }
        end


        def initialize(attack:, attack_curve: Curve::EaseOut, hold: 0.0, decay:, sustain_curve: Curve::EaseIn, sustain:, release:, release_curve: Curve::EaseOut, soundinfo:)
          @attack = attack
          @attack_curve = attack_curve
          @hold = hold
          @decay = decay
          @sustain_curve = sustain_curve
          @sustain = sustain
          @release = release
          @release_curve = release_curve
          @soundinfo = soundinfo
        end

        def note_on_envelope(sustain: false, &block)
          Enumerator.new do |yld|
            samplerate = @soundinfo.samplerate

            # attack
            rate = @attack * samplerate
            rate.to_i.times {|i|
              x = i.to_f / rate
              y = @attack_curve[x]
              yld << y
            }

            # hold
            rate = @hold * samplerate
            rate.to_i.times {|i|
              yld << 1.0
            }

            # decay
            rate = @decay * samplerate
            rate.to_i.times {|i|
              x = i.to_f / rate
              y = 1.0 - @release_curve[x]  * (1.0 - @sustain)
              yld << y
            }

            # sustain
            if sustain
              loop {
                yld << @sustain
              }
            end
          end.each(&block)
        end

        def note_off_envelope(&block)
          Enumerator.new do |yld|
            samplerate = @soundinfo.samplerate

            # release
            rate = @release * samplerate
            rate.to_i.times {|i|
              x = i.to_f / rate
              y = @sustain - (@release_curve[x] * @sustain)
              yld << y
            }
          end.each(&block)
        end

        def generator(note_perform, &block)
          Enumerator.new do |y|
            note_on = note_on_envelope(sustain: true)
            note_off = note_off_envelope

            loop {
              if note_perform.note_on?
                y << note_on.next
              else
                y << note_off.next
              end
            }
          end.each(&block)
        end
      end
    end
  end
end
