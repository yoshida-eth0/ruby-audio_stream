require 'audio_stream'

include AudioStream
include AudioStream::Fx


soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

# Track

#track1 = AudioInput.sin(454.0, 100, 2048, soundinfo: soundinfo)
track1 = AudioInput.device(1024*2*2*2)


# Audio FX

tuner = Tuner.new(soundinfo)


# Bus

stereo_out = AudioOutput.device(soundinfo: soundinfo)


# Mixer

track1
  .stream
  .fx(tuner)
  .subscribe_on_next {|tone|
    width = 30
    if tone.diff
      diff = (tone.diff * width / 100).round
      bar = ""
      if diff.negative?
        diff = diff.abs
        if width/2<diff
          diff = width/2
        end
        bar += "_" * (width/2 - diff)
        bar += "#" * diff
        bar += "@"
        bar += "_" * (width/2)
      else
        if width/2<diff
          diff = width/2
        end
        bar += "_" * (width/2)
        bar += "@"
        bar += "#" * diff
        bar += "_" * (width/2 - diff)
      end
      print "\r% 4.3fhz % 5s% 2d %s % 2.3f" % [tone.freq, tone.note, tone.octave, bar, tone.diff]

    else
      print "\r ---.---hz NOINPUT"
    end
  }

#track1
#  .stream
#  .send_to(stereo_out)


# start

conductor = Conductor.new(
  input: track1,
  output: nil
)
conductor.connect
conductor.join
