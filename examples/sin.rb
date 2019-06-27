require_relative '../lib/audiostream'


# Track

track1 = AudioInput.sin(440.0, 100, channels: 2)
track2 = AudioInput.sin(554.37, 100, channels: 2)
track3 = AudioInput.sin(659.26, 100, channels: 2)


# Audio FX

gain = AGain.new(0.3)


# Bus

soundinfo = RubyAudio::SoundInfo.new :channels => 2, :samplerate => 44100, :format => RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
stereo_out = AudioOutput.file("out.wav", soundinfo)

bus1 = AudioBus.new


# Mixer

track1
  .fx(gain)
  .send_to(bus1)

track2
  .fx(gain)
  .send_to(bus1)

track3
  .fx(gain)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

[track1, track2, track3].map(&:connect)

