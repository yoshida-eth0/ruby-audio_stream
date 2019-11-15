module AudioStream
  module Fx
    class Vocoder
      def initialize(soundinfo, shift: 0, bandwidth: 0.2)

        band_num = 16
        nyquist = soundinfo.samplerate * 0.5

        @modulator_bpfs = band_num.times.map {|i|
          [i, 6.875 * (2 ** (i*0.5 + 3 - (shift/12.0)))]
        }.select {|i, freq|
          0<freq && freq<nyquist
        }.map {|i, freq|
          [i, BandPassFilter.create(soundinfo, freq: freq, bandwidth: bandwidth)]
        }.to_h

        @carrier_bpfs = band_num.times.map {|i|
          [i, 6.875 * (2 ** (i*0.5 + 3))]
        }.select {|i, freq|
          0<freq && freq<nyquist
        }.map {|i, freq|
          [i, BandPassFilter.create(soundinfo, freq: freq, bandwidth: bandwidth)]
        }.to_h

        @band_keys = @modulator_bpfs.keys & @carrier_bpfs.keys
      end

      def process(input)
        carrier = Buffer.new(input.streams[0])
        modulator = Buffer.new(input.streams[1])

        dsts = @band_keys.map {|key|
          level = @modulator_bpfs[key].process(modulator).streams[0].max
          @carrier_bpfs[key].process(carrier).streams[0] * level
        }

        dst0 = dsts.inject(:+)
        Buffer.new(dst0)
      end
    end
  end
end
