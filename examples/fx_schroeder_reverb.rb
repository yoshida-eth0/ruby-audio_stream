require_relative 'example_options'


# Track

track1 = $input


# Fx

reverb = SchroederReverb.new($soundinfo, dry: -1, wet: -10)
#reverb = CombFilter.new($soundinfo, freq: 30.15 / 1000 * 44100, q: 0.7)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .fx(reverb)
  .send_to(stereo_out, gain: -6)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
