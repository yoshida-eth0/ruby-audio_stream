module AudioStream
  module Synth
    module Modulation
      class Adsr

        def initialize(attack:, attack_curve: Curve::EaseOut, hold: 0.0, decay:, sustain_curve: Curve::EaseOut, sustain:, release:, release_curve: Curve::EaseOut)
          @attack = attack
          @attack_curve = attack_curve
          @hold = hold
          @decay = decay
          @sustain_curve = sustain_curve
          @sustain = sustain
          @release = release
          @release_curve = release_curve
        end

        def note_on_envelope(samplerate, sustain: false, &block)
          Enumerator.new do |yld|
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
              y = 1.0 - @sustain_curve[x]  * (1.0 - @sustain)
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

        def note_off_envelope(samplerate, sustain: false, &block)
          Enumerator.new do |yld|
            # release
            rate = @release * samplerate
            rate.to_i.times {|i|
              x = i.to_f / rate
              y = 1.0 - @release_curve[x]
              yld << y
            }

            # sustain
            if sustain
              loop {
                yld << 0.0
              }
            end
          end.each(&block)
        end

        def amp_generator(note_perform, sustain: true, &block)
          Enumerator.new do |y|
            samplerate = note_perform.synth.soundinfo.samplerate

            note_on = note_on_envelope(samplerate, sustain: sustain)
            note_off = note_off_envelope(samplerate, sustain: sustain)
            last = 0.0

            loop {
              if note_perform.note_on?
                last = note_on.next
                y << last
              else
                y << note_off.next * last
              end
            }
          end.each(&block)
        end
        alias_method :balance_generator, :amp_generator

        def plot(samplerate=44100)
          note_on = note_on_envelope(samplerate, sustain: false)
          note_off = note_off_envelope(samplerate, sustain: false)
          last = 0.0

          xs = []
          ys = []

          note_on.each {|y|
            xs << xs.length
            ys << y
          }

          last = ys.last || 0.0
          note_off.each {|y|
            xs << xs.length
            ys << y * last
          }

          Plotly::Plot.new(data: [{x: xs, y: ys}])
        end
      end
    end
  end
end
