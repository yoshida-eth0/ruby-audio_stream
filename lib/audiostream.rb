require 'coreaudio'
require 'ruby-audio'
require 'fftw3'
require 'rx'


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

  def self.sin(hz, repeat, window_size: 1024, channels: 1)
    Rx::Observable.create do |observer|
      buf = RubyAudio::Buffer.float(window_size, channels)
      offset = 0

      repeat.times.each {|_|
        case channels
        when 1
          window_size.times.each {|i|
            buf[i] = Math.sin(hz / 44100.0 * 2 * Math::PI * (i + offset))
          }
        when 2
          window_size.times.each {|i|
            val = Math.sin(hz / 44100.0 * 2 * Math::PI * (i + offset))
            buf[i] = [val, val]
          }
        end
        offset += window_size
        observer.on_next(buf)
      }
      observer.on_completed
    end.publish
  end

  def self.empty(window_size: 1024, channels: 1)
    Rx::Observable.create do |observer|
      buf = RubyAudio::Buffer.float(window_size, channels)
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
  def initialize(out)
    super()
    @out = out
  end

  def on_next(a)
    a = [a].flatten
    window_size = a.map(&:size).max
    channels = a.first&.channels || 1
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
    @out.write(buf)
  end

  def on_error(error)
    puts error
    puts error.backtrace.join("\n")
    @out.close
  end

  def on_completed
    @out.close
  end

  def self.file(fname, soundinfo)
    sound = RubyAudio::Sound.open(fname, "w", soundinfo)
    new(sound)
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
