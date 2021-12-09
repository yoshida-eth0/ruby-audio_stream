require_relative 'example_options'


# Track

track1 = $input


# Fx

delay = Delay.new($soundinfo, time: 0.2, level: -6, feedback: -15)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .fx(delay)
  .send_to(stereo_out, gain: -6)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
