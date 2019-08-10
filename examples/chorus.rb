require_relative 'example_options'


# Track

track1 = $input


# Fx

compressor = Compressor.new(threshold: 0.3, ratio: 0.5)
chorus = Chorus.new($soundinfo, depth: 100, rate: 0.25)


# Bus

bus1 = AudioBus.new
stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .stereo
  .fx(chorus)
  .send_to(bus1, gain: 1.0, pan: 0.0)

bus1
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
