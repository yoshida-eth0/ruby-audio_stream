module AudioStream
  module Synth
    class Osc

      attr_reader :shape
      attr_reader :volume
      attr_reader :pan
      attr_reader :tune_semis
      attr_reader :tune_cents
      attr_reader :sym
      attr_reader :phase
      attr_reader :sync
      attr_reader :uni_num
      attr_reader :uni_detune

      # @param shape [Synth::Shape] oscillator waveform shape
      # @param volume [Float] oscillator volume. mute=0.0 max=1.0
      # @param pan [Float] oscillator pan. left=-1.0 center=0.0 right=1.0 (-1.0~1.0)
      # @param tune_semis [Integer] oscillator pitch semitone
      # @param tune_cents [Integer] oscillator pitch cent
      # @param sym [nil] TODO not implemented
      # @param phase [Float] oscillator waveform shape start phase percent (0.0~1.0,nil) nil=random
      # @param sync [Integer] TODO not implemented
      # @param uni_num [Float] oscillator voicing number (1.0~16.0)
      # @param uni_detune [Float] oscillator voicing detune percent. 0.01=1cent 1.0=semitone (0.0~1.0)
      def initialize(shape: Shape::Sine, volume: 1.0, pan: 0.0, tune_semis: 0, tune_cents: 0, sym: 0, phase: nil, sync: 0, uni_num: 1.0, uni_detune: 0.0)
        @shape = shape

        @volume = Param.create(volume)
        @pan = Param.create(pan)
        @tune_semis = Param.create(tune_semis)
        @tune_cents = Param.create(tune_cents)

        @sym = Param.create(sym)
        @phase = Param.create(phase)
        @sync = Param.create(sync)

        @uni_num = Param.create(uni_num)
        @uni_detune = Param.create(uni_detune)
      end
    end
  end
end
