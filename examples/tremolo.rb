require_relative 'example_options'


# Track

track1 = $input


# Fx

tremolo = Tremolo.new($soundinfo, freq: 5, depth: 0.8)


# Bus

bus1 = AudioBus.new
stereo_out = AudioOutput.device


# Mixer

track1
  .stream
  .fx(tremolo)
  .send_to(bus1)

bus1
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
