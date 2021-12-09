require_relative 'example_options'


# Track

track1 = $input


# Fx

noise_gate = NoiseGate.new(threshold: 0.001)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .fx(noise_gate)
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
