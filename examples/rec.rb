require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx


track1 = AudioInput.device

soundinfo = RubyAudio::SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)
stereo_out = AudioOutput.file("out.wav", soundinfo).stream

track1
  .send_to(stereo_out)

track1.connect