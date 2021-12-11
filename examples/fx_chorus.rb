require_relative 'example_options'


# Track

track1 = $input


# Fx

chorus = Chorus.new($soundinfo, depth: 100, rate: 4)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .stereo
  .fx(chorus)
  .send_to(stereo_out, gain: -6)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
