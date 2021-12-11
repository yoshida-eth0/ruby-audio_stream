$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'benchmark'
require 'audio_stream'

include AudioStream
include AudioStream::Fx

n = 100

soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

src0_arr = Array.new(1024) {|i| Random.rand}
src1_arr = Array.new(1024) {|i| Random.rand}

src0_vdsp = Vdsp::DoubleArray.create(src0_arr)
src1_vdsp = Vdsp::DoubleArray.create(src1_arr)
src = AudioStream::Buffer.new(src0_vdsp, src1_vdsp)


fxs = [
  "Dynamics fx",
  AGain.new(level: -6),
  Panning.new(pan: 1.0),
  Compressor.new(threshold: 0.5, ratio: 0.5),
  NoiseGate.new(threshold: 0.001),

  "Distortion fx",
  Distortion.new(gain: 50, level: -20),

  "Modulation fx",
  Chorus.new(soundinfo, depth: 100, rate: 4),
  Phaser.new(soundinfo, rate: 1.4, depth: 3.5, freq: 800, dry: -6, wet: -6),
  Tremolo.new(soundinfo, freq: 5, depth: 0.2),
  Delay.new(soundinfo, time: 0.2, level: -6, feedback: -15),
  CombFilter.new(soundinfo, freq: 1000, q: 0.8),
  SchroederReverb.new(soundinfo, dry: -1, wet: -10),
  -> {
    impulse = AudioInput.file(File.dirname(__FILE__)+"/impulse_shaker.wav", soundinfo: soundinfo)
      .connect.to_a.map(&:stereo)
    ConvolutionReverb.new(impulse, dry: -6, wet: -6)
  }[],

  "Window fx",
  HanningWindow.instance,

  "Filter fx",
  LowPassFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q),
  HighPassFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q),
  LowShelfFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q, gain: 5),
  HighShelfFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q, gain: 5),
  BandPassFilter.create(soundinfo, freq: 440.0, bandwidth: 0.5),
  PeakingFilter.create(soundinfo, freq: 440.0, bandwidth: 0.5, gain: 5),
  AllPassFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q),

  "Equalizer fx",
  Equalizer2band.new(soundinfo, lowgain: 3, highgain: 5),
  Equalizer3band.new(soundinfo, lowgain: 3, midgain: 1, highgain: 5),
  GraphicEqualizer.new(soundinfo)
    .add(freq: 100, gain: 8)
    .add(freq: 200, gain: 4)
    .add(freq: 400, gain: -4)
    .add(freq: 800, gain: -8)
    .add(freq: 1600, gain: 4)
    .add(freq: 3200, gain: 8),
]


fxs.each {|fx|
  if String===fx
    puts
    puts "[#{fx}]"

  else
    time = Benchmark.realtime do
      n.times {
        fx.process(src)
      }
    end

    name = fx.class.name.split('::').last
    puts "  #{name.ljust(20)} : #{time}"
  end
}
