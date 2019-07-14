module AudioStream
  module Synth
    class Amp

      attr_reader :volume
      attr_reader :pan
      attr_reader :tune_semis
      attr_reader :tune_cents
      attr_reader :uni_num
      attr_reader :uni_detune

      # @param volume [Float] master volume. mute=0.0 max=1.0
      # @param pan [Float] master pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
      # @param tune_semis [Integer] master pitch semitone
      # @param tune_cents [Integer] master pitch cent
      # @param uni_num [Float] master voicing number (1.0~16.0)
      # @param uni_detune [Float] master voicing detune percent. 0.01=1cent 1.0=semitone (0.0~1.0)
      def initialize(shape: Shape::Sine, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, uni_num: 1.0, uni_detune: 0.0)
        @volume = Param.create(volume)
        @pan = Param.create(pan)
        @tune_semis = Param.create(tune_semis)
        @tune_cents = Param.create(tune_cents)

        @uni_num = Param.create(uni_num)
        @uni_detune = Param.create(uni_detune)
      end
    end
  end
end
