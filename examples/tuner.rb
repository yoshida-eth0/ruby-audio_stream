require 'audio_stream/core_ext'

include AudioStream
include AudioStream::Fx


soundinfo = RubyAudio::SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

# Track

#track1 = AudioInput.sin(454.0, 100, 2048, soundinfo: soundinfo)
track1 = AudioInput.device


# Audio FX

tuner = Tuner.new(soundinfo)


# Bus

stereo_out = AudioOutput.device


# Mixer

track1
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
#  .send_to(stereo_out)


# start

[track1].map(&:connect)

