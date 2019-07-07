require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx


soundinfo = RubyAudio::SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)


# Track

track1 = AudioInput.sin(440.0, 100, soundinfo: soundinfo)
track2 = AudioInput.sin(554.37, 100, soundinfo: soundinfo)
track3 = AudioInput.sin(659.26, 100, soundinfo: soundinfo)


# Audio FX

gain = AGain.new(level: 0.3)


# Bus

#stereo_out = AudioOutput.file("out.wav", soundinfo)
stereo_out = AudioOutput.device
bus1 = AudioBus.new


# Mixer

track1
  .stream
  .fx(gain)
  .send_to(bus1)

track2
  .stream
  .fx(gain)
  .send_to(bus1)

track3
  .stream
  .fx(gain)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: [track1, track2, track3],
  output: stereo_out
)
conductor.connect
conductor.join
