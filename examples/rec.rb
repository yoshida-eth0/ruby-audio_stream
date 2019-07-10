require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)


# Input

track1 = AudioInput.device
track2 = AudioInputMetronome.new(60.0, soundinfo: soundinfo)


# Fx



# Bus

bus1 = AudioBus.new
file_out = AudioOutput.file("out.wav", soundinfo: soundinfo)
stereo_out = AudioOutput.device(soundinfo: soundinfo)


# Mixer

track1
  .stream
  .send_to(file_out)
  .send_to(bus1)

bus1
  .send_to(stereo_out, gain: 0.5)

track2
  .stream
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: [track1, track2],
  output: [file_out, stereo_out]
)
conductor.connect
conductor.join
