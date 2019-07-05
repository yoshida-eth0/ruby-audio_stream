require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx

soundinfo = RubyAudio::SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)


# Input

track1 = AudioInput.device.stream
track2 = AudioInput.file(File.dirname(__FILE__)+"/drum.wav").stream


# Fx

noise_gate = Compressor.new(threshold: 0.1, ratio: 10.0)
compressor = Compressor.new(threshold: 0.3, ratio: 0.5)
distortion = Distortion.new(gain: 300, level:0.1)
chorus = Chorus.new(soundinfo, depth: 100, rate: 0.25)
eq = Equalizer2band.new(soundinfo, lowgain: 0.0, highgain: -10.0)


# Bus

bus1 = AudioBus.new
file_out = AudioOutput.file("out.wav", soundinfo)
stereo_out = AudioOutput.device


# Mixer

track1
  .send_to(bus1)
  .send_to(file_out)

bus1
  .fx(noise_gate)
  .send_to(stereo_out, gain: 0.5)

track2
  .send_to(stereo_out)


# start

[track1, track2, stereo_out].map {|stream|
  Thread.start(stream) {|stream|
    stream.connect
  }
}.map(&:join)
