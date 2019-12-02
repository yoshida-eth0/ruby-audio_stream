module AudioStream
  module Fx
    class Vocoder
      include MultiAudioInputtable

      # @param soundinfo [AudioStream::SoundInfo]
      # @param shift [Float] modulator pitch shift. 1.0=1semitone
      # @param bandwidth [Float] bandwidth (octave)
      def initialize(soundinfo, shift: 0, bandwidth: 0.2)
        regist_audio_input(:main)
        regist_audio_input(:side)

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

      def process(inputs)
        carrier = inputs[:main]
        modulator = inputs[:side]

        channels = [carrier.channels, modulator.channels].max
        if channels==2
          carrier = carrier.stereo
          modulator = modulator.stereo
        end

        dsts = channels.times.map {|i|
          @band_keys.map {|key|
            level = @modulator_bpfs[key].process(modulator).streams[i].max
            @carrier_bpfs[key].process(carrier).streams[i] * level
          }.inject(:+)
        }

        Buffer.new(*dsts)
      end
    end
  end
end
