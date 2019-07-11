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

      def self.generator(note_perform, param1, param2)
        mods = param1.mods.map {|mod, depth|
          mod.generator(note_perform)
        }
        mods += param2.mods.map {|mod, depth|
          mod.generator(note_perform)
        }
        # TODO: impl depth

        Enumerator.new do |y|
          loop {
            y << mods.map(&:next).inject(1.0, &:*)
          }
        end
      end
    end
  end
end
