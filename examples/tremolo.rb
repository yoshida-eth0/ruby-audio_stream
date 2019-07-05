require_relative 'example_options'


# Track

track1 = $input_stream


# Fx

tremolo = Tremolo.new($soundinfo, freq: 5, depth: 0.8)


# Bus

bus1 = AudioBus.new
stereo_out = AudioOutput.device


# Mixer

track1
  .fx(tremolo)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

[track1, stereo_out].map {|stream|
  Thread.start(stream) {|stream|
    stream.connect
  }
}.map(&:join)
