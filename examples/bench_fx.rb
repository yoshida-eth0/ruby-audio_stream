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

lpf_time = Benchmark.realtime do
  lpf = LowPassFilter.create(soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q)
  n.times {
    lpf.process(src)
  }
end

a_gain_time = Benchmark.realtime do
  a_gain = AGain.new(level: -6)
  n.times {
    a_gain.process(src)
  }
end

chorus_time = Benchmark.realtime do
  chorus = Chorus.new(soundinfo, depth: 100, rate: 0.25)
  n.times {
    chorus.process(src)
  }
end

compressor_time = Benchmark.realtime do
  compressor = Compressor.new(threshold: 0.5, ratio: 0.5)
  n.times {
    compressor.process(src)
  }
end

convolution_reverb_time = Benchmark.realtime do
  impulse = AudioInput.file(File.dirname(__FILE__)+"/impulse_response.wav", soundinfo: soundinfo)
  convolution_reverb = ConvolutionReverb.new(impulse.connect.to_a.map(&:stereo), dry: 0.0, wet: 1.0)
  n.times {
    convolution_reverb.process(src)
  }
end

delay_time = Benchmark.realtime do
  delay = Delay.new(soundinfo, time: 0.2, level: -6, feedback: -15)
  n.times {
    delay.process(src)
  }
end

comb_filter_time = Benchmark.realtime do
  comb_filter = CombFilter.new(soundinfo, freq: 1000, q: 0.8)
  n.times {
    comb_filter.process(src)
  }
end

schroeder_reverb_time = Benchmark.realtime do
  schroeder_reverb = SchroederReverb.new(soundinfo, dry: -1, wet: -10)
  n.times {
    schroeder_reverb.process(src)
  }
end

distortion_time = Benchmark.realtime do
  distortion = Distortion.new(gain: 50, level: -20)
  n.times {
    distortion.process(src)
  }
end

equalizer_2band_time = Benchmark.realtime do
  equalizer_2band = Equalizer2band.new(soundinfo, lowgain: 3, highgain: 5)
  n.times {
    equalizer_2band.process(src)
  }
end

equalizer_3band_time = Benchmark.realtime do
  equalizer_3band = Equalizer3band.new(soundinfo, lowgain: 3, midgain: 1, highgain: 5)
  n.times {
    equalizer_3band.process(src)
  }
end

graphic_equalizer_time = Benchmark.realtime do
  graphic_equalizer = GraphicEqualizer.new(soundinfo)
    .add(freq: 100, gain: 8)
    .add(freq: 200, gain: 4)
    .add(freq: 400, gain: -4)
    .add(freq: 800, gain: -8)
    .add(freq: 1600, gain: 4)
    .add(freq: 3200, gain: 8)
  n.times {
    graphic_equalizer.process(src)
  }
end

hanning_window_time = Benchmark.realtime do
  hanning_window = HanningWindow.instance
  n.times {
    hanning_window.process(src)
  }
end

panning_time = Benchmark.realtime do
  panning = Panning.new(pan: 1.0)
  n.times {
    panning.process(src)
  }
end

tremolo_time = Benchmark.realtime do
  tremolo = Tremolo.new(soundinfo, freq: 5, depth: 0.2)
  n.times {
    tremolo.process(src)
  }
end

puts "lpf time                : #{lpf_time}"
puts "again time              : #{a_gain_time}"
puts "chorus time             : #{chorus_time}"
puts "compressor time         : #{compressor_time}"
puts "convolution_reverb time : #{convolution_reverb_time}"
puts "delay time              : #{delay_time}"
puts "comb_filter time        : #{comb_filter_time}"
puts "schroeder_reverb time   : #{schroeder_reverb_time}"
puts "distortion time         : #{distortion_time}"
puts "equalizer_2band time    : #{equalizer_2band_time}"
puts "equalizer_3band time    : #{equalizer_3band_time}"
puts "graphic_equalizer time  : #{graphic_equalizer_time}"
puts "hanning_window time     : #{hanning_window_time}"
puts "panning time            : #{panning_time}"
puts "tremolo time            : #{tremolo_time}"
