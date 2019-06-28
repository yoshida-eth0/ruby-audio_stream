require 'ruby-audio'
require 'coreaudio'
require 'numru/fftw3'
require 'rx'

include NumRu

class AudioInput

  def self.file(fname, window_size=1024)
    Rx::Observable.create do |observer|
      sound = RubyAudio::Sound.open(fname)
      buf = RubyAudio::Buffer.float(window_size, sound.info.channels)
      while sound.read(buf)!=0
        observer.on_next(buf)
      end
      observer.on_completed
    end.publish
  end

  def self.buffer(buf)
    Rx::Observable.create do |observer|
      observer.on_next(buf)
      observer.on_completed
    end.publish
  end

  def self.device(window_size=1024)
    Rx::Observable.create do |observer|
      dev = CoreAudio.default_input_device
      inbuf = dev.input_buffer(window_size)
      inbuf.start

      channels = dev.input_stream.channels
      buf = RubyAudio::Buffer.float(window_size, channels)

      loop {
        na = inbuf.read(window_size)
        window_size.times {|i|
          buf[i] = na[(na.dim*i)...(na.dim*(i+1))].to_a.map{|s| s / 0x7FFF.to_f}
        }
        observer.on_next(buf)
      }
      observer.on_completed
    end.publish
  end

  def self.sin(hz, repeat, window_size=1024, soundinfo:)
    Rx::Observable.create do |observer|
      buf = RubyAudio::Buffer.float(window_size, soundinfo.channels)

      phase = hz.to_f / soundinfo.samplerate * 2 * Math::PI
      offset = 0

      repeat.times.each {|_|
        case soundinfo.channels
        when 1
          window_size.times.each {|i|
            buf[i] = Math.sin(phase * (i + offset))
          }
        when 2
          window_size.times.each {|i|
            val = Math.sin(phase * (i + offset))
            buf[i] = [val, val]
          }
        end
        offset += window_size
        observer.on_next(buf)
      }
      observer.on_completed
    end.publish
  end

  def self.empty(window_size=1024, soundinfo:)
    Rx::Observable.create do |observer|
      buf = RubyAudio::Buffer.float(window_size, soundinfo.channels)
      observer.on_next(buf)
      observer.on_completed
    end.publish
  end
end

class AudioBus < Rx::Subject
  def initialize
    super
    @observables = []
    @zip_observable = nil
    @detach = nil
  end

  def add(observable)
    @observables << observable
    if @detach
      @detach.unsubscribe
    end

    @zip_observable = Rx::Observable.zip(*@observables)
    @detach = @zip_observable.subscribe(self)
  end
end

class AudioOutput < AudioBus
  def self.file(fname, soundinfo)
    AudioOutputFile.new(fname, soundinfo)
  end

  def self.device
    AudioOutputDevice.new
  end
end

class AudioOutputFile < AudioOutput
  def initialize(fname, soundinfo)
    super()
    @sound = RubyAudio::Sound.open(fname, "w", soundinfo)
  end

  def on_next(a)
    a = [a].flatten
    window_size = a.map(&:size).max
    channels = a.first&.channels
    buf = RubyAudio::Buffer.float(window_size, channels)

    case channels
    when 1
      a.each {|x|
        x.size.times.each {|i|
          if buf[i]
            buf[i] += x[i]
          else
            buf[i] = x[i]
          end
        }
      }
    when 2
      a.each {|x|
        x.size.times.each {|i|
          if buf[i]
            buf[i] = buf[i].zip(x[i]).map {|a| a[0] + a[1]}
          else
            buf[i] = x[i]
          end
        }
      }
    end
    @sound.write(buf)
  end

  def on_error(error)
    puts error
    puts error.backtrace.join("\n")
    @sound.close
  end

  def on_completed
    @sound.close
  end
end

class AudioOutputDevice < AudioOutput
  def initialize(window_size=1024)
    super()
    dev = CoreAudio.default_output_device
    @channels = dev.output_stream.channels
    @buf = dev.output_buffer(window_size)
    @buf.start
  end

  def on_next(a)
    a = [a].flatten
    window_size = a.map(&:size).max
    channels = a.first&.channels

    case @channels
    when 1
      a = a.map {|x| StereoToMono.new.process(x)}
    when 2
      a = a.map {|x| MonoToStereo.new.process(x)}
    end

    na = NArray.sint(@channels, window_size)
    a.each {|x|
      xa = x.to_a.flatten.map{|f| (f*0x7FFF).round}
      na2 = NArray.sint(@channels, window_size)
      na2[0...xa.length] = xa
      na += na2
    }
    @buf << na
  end

  def on_error(error)
    puts error
    puts error.backtrace.join("\n")
  end

  def on_completed
  end
end

module Rx::Observable
  def fx(effector)
    map(&effector.:process)
  end

  def send_to(bus)
    bus.add(self)
    self
  end
end


class AGain
  def initialize(level)
    @level = level
  end

  def process(input)
    output = RubyAudio::Buffer.float(input.size, input.channels)
    case input.channels
    when 1
      input.each_with_index {|f, i|
        output[i] = f * @level
      }
    when 2
      input.each_with_index {|fa, i|
        output[i] = fa.map {|f| f * @level}
      }
    end
    output
  end
end

class StereoToMono
  def process(input)
    case input.channels
    when 1
      input
    when 2
      output = RubyAudio::Buffer.float(input.size, 1)
      input.each_with_index {|fa, i|
        output[i] = fa.sum / 2.0
      }
      output
    end
  end
end

class MonoToStereo
  def process(input)
    case input.channels
    when 1
      output = RubyAudio::Buffer.float(input.size, 2)
      input.each_with_index {|f, i|
        output[i] = [f, f]
      }
      output
    when 2
      input
    end
  end
end

class Tuner

  Tune = Struct.new("Tune", :freq, :note_num, :note, :octave, :diff, :gain, keyword_init: true)

  FREQ_TABLE = 10.times.map {|i|
    a = 13.75 * 2 ** i
    12.times.map {|j|
      a * (2 ** (j / 12.0))
    }
  }.flatten.freeze

  NOTE_TABLE = ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"].freeze
    
  def initialize(soundinfo, window: nil)
    @samplerate = soundinfo.samplerate
    @window = window || HanningWindow.new
  end

  def process(input)
    window_size = input.size

    # mono window
    input = StereoToMono.new.process(input)
    @window.process!(input)

    gain = input.to_a.flatten.max
    freq = nil

    if 0.01<gain
      # fft
      na = NArray.float(1, window_size)
      na[0...na.size] = input.to_a
      fft = FFTW3.fft(na, FFTW3::FORWARD)

      amp = fft.map {|c|
        c.real**2 + c.imag**2
      }.real.to_a.flatten

      # peak
      i = amp.index(amp.max)

      if window_size/2<i
        j = window_size - i
        if (amp[i]-amp[j]).abs<=0.0000001
          i = j
        end
      end

      # freq
      freq_rate = @samplerate / window_size

      if 0<i && i<window_size-1
        freq_sum = amp[i-1] * (i-1) * freq_rate
        freq_sum += amp[i] * i * freq_rate
        freq_sum += amp[i+1] * (i+1) * freq_rate

        amp_sum = amp[i-1] + amp[i] + amp[i+1]

        freq = freq_sum / amp_sum
      else
        freq = i * freq_rate
      end

      struct(freq)
    else
      Tune.new
    end
  end

  def struct(freq)
    index = FREQ_TABLE.bsearch_index {|x| x>=freq}
    if !index || FREQ_TABLE.length<=index+1
      return Tune.new
    end

    if 0<index && freq-FREQ_TABLE[index-1] < FREQ_TABLE[index]-freq
      diff = (freq-FREQ_TABLE[index-1]) / (FREQ_TABLE[index]-FREQ_TABLE[index-1]) * 100
      index -= 1
    else
      diff = (freq-FREQ_TABLE[index]) / (FREQ_TABLE[index+1]-FREQ_TABLE[index]) * 100
    end
    note_num = index + 9
    note = NOTE_TABLE[index%12]
    octave = (index-3)/12

    Tune.new(
      freq: freq,
      note_num: note_num,
      note: note,
      octave: octave,
      diff: diff
    )
  end
end

class HanningWindow
  def process(input)
    output = input.clone
    process!(output)
    output
  end

  def process!(input)
    window_size = input.size
    window_max = input.size - 1
    channels = input.channels

    period = 2 * Math::PI / window_max

    case channels
    when 1
      window_size.times {|i|
        input[i] *= 0.5 - 0.5 * Math.cos(i * period)
      }
    when 2
      window_size.times {|i|
        gain = 0.5 - 0.5 * Math.cos(i * period)
        input[i] = input[i].map {|f| f * gain}
      }
    end
  end
end

class Tremolo
  def initialize(soundinfo)
    @samplerate = soundinfo.samplerate
    @freq = 8
    @depth = 0.8
    @phase = 0
  end

  def process(input)
    output = input.clone
    process!(output)
    output
  end

  def process!(input)
    window_size = input.size
    channels = input.channels

    period = 2 * Math::PI * @freq / @samplerate

    case channels
    when 1
      input.each_with_index {|f, i|
        input[i] *= 1.0 + @depth * Math.sin((i + @phase) * period)
      }
    when 2
      input.each_with_index {|fa, i|
        gain = 1.0 + @depth * Math.sin((i + @phase) * period)
        input[i] = fa.map {|f| f * gain}
      }
    end
    @phase += window_size
  end
end
