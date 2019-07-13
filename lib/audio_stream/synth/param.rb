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

      def self.amp_generator(note_perform, param1, param2=nil)
        if param2==nil
          param2 = Param.new(1.0)
        end

        # value
        value = param1.value * param2.value

        # mods
        mods = []
        param1.mods.each {|mod, depth|
          mods << mod.amp_generator(note_perform, depth)
        }
        param2.mods.each {|mod, depth|
          mods << mod.amp_generator(note_perform, depth)
        }

        Enumerator.new do |y|
          loop {
            depth = mods.map(&:next).inject(1.0, &:*)
            y << value * depth
          }
        end
      end

      def self.balance_generator(note_perform, param1, param2=nil)
        if param2==nil
          param2 = Param.new(0.0)
        end

        # value
        value = param1.value + param2.value

        # mods
        mods = []
        param1.mods.each {|mod, depth|
          mods << mod.balance_generator(note_perform, depth)
        }
        param2.mods.each {|mod, depth|
          mods << mod.balance_generator(note_perform, depth)
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
