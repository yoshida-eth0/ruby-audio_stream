module AudioStream
  module Synth
    class Osc

      module Source
        Sin = ->(rad) { Math.sin(rad) }
      end

      def initialize(src: Source::Sin, volume: 1.0, volume_mods: nil, sym: 0, phase: 0, sync: 0, uni_num: 1, uni_detune: 0, soundinfo:)
        @src = src

        @volume = volume
        @volume_mods = volume_mods

        @pan = 0.0
        @tune_semis = 0
        @tune_cents = 0

        @sym = sym
        @phase = phase
        @sync = sync

        @uni_num = uni_num
        @uni_detune = uni_detune

        @soundinfo = soundinfo
      end

      def generator(note_perform, &block)
        Enumerator.new do |y|
          buf = Buffer.float(@soundinfo.window_size, @soundinfo.channels)

          offset = 0

          loop {
            hz = note_perform.hz(semis: @tune_semis, cents: @tune_cents).to_f
            delta = hz / @soundinfo.samplerate * 2 * Math::PI

            #volume_mods = note_perform.volume_mods

            case @soundinfo.channels
            when 1
              @soundinfo.window_size.times.each {|i|
                buf[i] = Math.sin(delta * (i + offset))
              }
            when 2
              @soundinfo.window_size.times.each {|i|
                val = Math.sin(delta * (i + offset))
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
