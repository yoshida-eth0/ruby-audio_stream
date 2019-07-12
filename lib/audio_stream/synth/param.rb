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

      def add(mod, depth: 1.0)
        @mods << [mod, depth || 1.0]
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
          mods << [mod.amp_generator(note_perform), depth]
        }
        param2.mods.each {|mod, depth|
          mods << [mod.amp_generator(note_perform), depth]
        }

        Enumerator.new do |y|
          loop {
            depth = mods.map {|mod, depth|
              bottom = 1.0 - depth
              mod.next * depth + bottom
            }.inject(1.0, &:*)

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
          mods << [mod.balance_generator(note_perform), depth]
        }
        param2.mods.each {|mod, depth|
          mods << [mod.balance_generator(note_perform), depth]
        }

        Enumerator.new do |y|
          loop {
            depth = mods.map {|mod, depth|
              mod.next * depth
            }.sum

            y << value + depth
          }
        end
      end
    end
  end
end
