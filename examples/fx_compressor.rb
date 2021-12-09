require_relative 'example_options'


# Track

track1 = $input


# Fx

compressor = Compressor.new(threshold: 0.4, ratio: 0.2)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .stereo
  .fx(compressor)
  .send_to(stereo_out, gain: -6)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
