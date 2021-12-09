require_relative 'example_options'


# Track

modulator = $input
#modulator = AudioInput.file(File.dirname(__FILE__)+"/modulator.wav", soundinfo: $soundinfo).connect
#carrier = AudioInput.file(File.dirname(__FILE__)+"/canon.wav", soundinfo: $soundinfo).connect.seek(1024*4)
carrier = AudioInput.file(File.dirname(__FILE__)+"/canon.wav", soundinfo: $soundinfo).connect


# Fx

vocoder = Vocoder.new($soundinfo)
compressor = Compressor.new(threshold: 0.4, ratio: 0.2)


# Bus

bus1 = AudioBus.new
stereo_out = AudioOutput.device(soundinfo: $soundinfo)
#stereo_out = AudioOutput.file("vocoder_out.wav", soundinfo: $soundinfo)


# Mixer

modulator
  .fx(compressor)
  .send_to(bus1)

carrier
  .fx(vocoder, side: bus1)
  .fx(compressor)
  .send_to(stereo_out, gain: -1)


# start

conductor = Conductor.new(
  input: [modulator, carrier],
  output: stereo_out
)
conductor.connect
conductor.join
