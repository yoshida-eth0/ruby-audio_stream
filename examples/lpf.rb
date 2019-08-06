require_relative 'example_options'


# Track

track1 = $input


# Fx

lpf = LowPassFilter.create($soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q)
hpf = HighPassFilter.create($soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q)
bpf = BandPassFilter.create($soundinfo, freq: 440.0, bandwidth: 10.0)
lsf = LowShelfFilter.create($soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q, gain: 1.0)
hsf = HighShelfFilter.create($soundinfo, freq: 440.0, q: BiquadFilter::DEFAULT_Q, gain: 1.0)
eq_2band = Equalizer2band.new($soundinfo, lowgain: -15.0, highgain: 15.0)


# Bus

stereo_out = AudioOutput.device(soundinfo: $soundinfo)


# Mixer

track1
  .fx(StereoToMono.instance)
  .fx(lpf)
  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: stereo_out
)
conductor.connect
conductor.join
