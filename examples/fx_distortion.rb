require_relative 'example_options'


# Track

track1 = $input


# Fx

noise_gate = Compressor.new(threshold: 0.1, ratio: 10.0)
compressor = Compressor.new(threshold: 0.3, ratio: 0.5)
distortion = Distortion.new(gain: 50, level: -20)
eq_2band = Equalizer2band.new($soundinfo, lowgain: 0.0, highgain: -10.0)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  #.fx(noise_gate)
  #.fx(compressor)
  .fx(distortion)
  .send_to(stereo_out, gain: -6)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
