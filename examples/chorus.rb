require_relative 'example_options'


# Track

track1 = $input_stream


# Fx

noise_gate = Compressor.new(threshold: 0.1, ratio: 10.0)
compressor = Compressor.new(threshold: 0.3, ratio: 0.5)
chorus = Chorus.new($soundinfo)


# Bus

bus1 = AudioBus.new
stereo_out = AudioOutput.device


# Mixer

track1
  .fx(chorus)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

[track1, stereo_out].map {|stream|
  Thread.start(stream) {|stream|
    stream.connect
  }
}.map(&:join)
