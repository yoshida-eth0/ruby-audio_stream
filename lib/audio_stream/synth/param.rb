module AudioStream
  module Synth
    class Param

      attr_accessor :value
      attr_reader :mods

      def initialize(value, mods={})
        @value = value
        @mods = []

        mods.each {|mod, depth|
          add(mod, depth)
        }
      end

      # @param mod [Synth::Modulation]
      # @param depth [Float] (-1.0~1.0)
      def add(mod, depth: 1.0)
        depth ||= 1.0
        if depth<-1.0
          depth = -1.0
        elsif 1.0<depth
          depth = 1.0
        end

        @mods << [mod, depth]
        self
      end

      def self.create(value)
        if Param===value
          value
        else
          new(value)
        end
      end

      def self.amp_generator(note_perform, samplerate, *params)
        params = params.flatten.compact

        # value
        value = params.map(&:value).sum

        # mods
        mods = []
        params.each {|param|
          param.mods.each {|mod, depth|
            mods << mod.amp_generator(note_perform, samplerate, depth)
          }
        }

        Enumerator.new do |y|
          loop {
            depth = mods.map(&:next).inject(1.0, &:*)
            y << value * depth
          }
        end
      end

      def self.balance_generator(note_perform, samplerate, *params, center: 0)
        params = params.flatten.compact

        # value
        value = params.map(&:value).sum
        value -= (params.length - 1) * center

        # mods
        mods = []
        params.each {|param|
          param.mods.each {|mod, depth|
            mods << mod.balance_generator(note_perform, samplerate, depth)
          }
        }

        Enumerator.new do |y|
          loop {
            depth = mods.map(&:next).sum
            y << value + depth
          }
        end
      end
    end
  end
end
