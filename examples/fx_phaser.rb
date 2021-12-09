require_relative 'example_options'


# Track

track1 = $input


# Fx

phaser1 = Phaser.new($soundinfo, rate: 1.4, depth: 3.5, freq: 800, dry: -6, wet: -6)
phaser2 = Phaser.new($soundinfo, rate: 1.83, depth: 3.5, freq: 1357, dry: -6, wet: -6)


# Bus

bus1 = AudioBus.new
bus2 = AudioBus.new
stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .mono
  .fx(phaser1)
  .fx(phaser2)
  .send_to(stereo_out, gain: -1)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
