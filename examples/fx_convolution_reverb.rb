require_relative 'example_options'


# Track

track1 = $input


# Fx

#impulse = AudioInput.file(File.dirname(__FILE__)+"/impulse_shaker.wav", soundinfo: $soundinfo).connect
impulse = AudioInput.file(File.dirname(__FILE__)+"/impulse_shaker_smallhall.wav", soundinfo: $soundinfo).connect
#impulse = AudioInput.file(File.dirname(__FILE__)+"/impulse_shaker_bigroom.wav", soundinfo: $soundinfo).connect
pp impulse
reverb = ConvolutionReverb.new(impulse, dry: -6, wet: -6)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .fx(reverb)
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
