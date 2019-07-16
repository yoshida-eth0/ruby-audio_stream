module AudioStream
  module Synth
    module Modulation
      class Glide

        # @param time [Float] glide time sec (0.0~)
        def initialize(time:)
          @time = time.to_f

          @base = 0.0
          @current = 0.0
          @target = 0.0
          @diff = 0.0
        end

        def base=(base)
          base = base.to_f

          @base = base
          @current = base
          @target = base
          @diff = 0.0
        end

        def target=(target)
          @target = target
          @diff = target - @current
        end

        def generator(note, samplerate, &block)
          Enumerator.new do |yld|
            rate = @time * samplerate

            loop {
              if note.note_on?
                # Note On
                if 0<@time && @target!=@current
                  # Gliding
                  x = @diff / rate
                  if x.abs<(@target-@current).abs
                    @current += x
                  else
                    @current = @target
                  end

                  yld << @current - @base
                else
                  # Stay
                  yld << @target - @base
                end
              else
                # Note Off
                @current = 0.0
                @target = 0.0
                @diff = 0.0
                yld << 0.0
              end
            }
          end.each(&block)
        end

        def balance_generator(note, samplerate, depth, &block)
          generator(note, samplerate).lazy.map {|val|
            val * depth
          }.each(&block)
        end

        def to_param
          @param ||= Param.create(0).add(self)
        end
      end
    end
  end
end
