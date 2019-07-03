module AudioStream
  class Buffer < RubyAudio::Buffer
    def plot(soundinfo=nil)
      Plot.new(self, soundinfo)
    end

    def +(other)
      unless RubyAudio::Buffer===other
        raise Error, "right operand is not Buffer: #{other}"
      end
      if self.size!=other.size
        raise Error, "Buffer.size is not match: self.size=#{self.size} other.size=#{other.size}"
      end

      channels = [self.channels, other.channels].max
      window_size = self.size

      buf = Buffer.float(window_size, channels)

      case channels
      when 1
        [self, other].each {|x|
          x.size.times.each {|i|
            if buf[i]
              buf[i] += x[i]
            else
              buf[i] = x[i]
            end
          }
        }
      when 2
        m2s = MonoToStereo.new
        a = [
          m2s.process(self),
          m2s.process(other),
        ]
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

      buf
    end

    def to_na
      window_size = self.size
      channels = self.channels

      na = NArray.float(channels, window_size)
      na[0...na.size] = self.to_a.flatten

      na
    end

    def self.from_na(na)
      channels = na.shape[0]
      window_size = na.size / channels

      buf = self.float(window_size, channels)

      case channels
      when 1
        window_size.times {|i|
          buf[i] = na[i].real
        }
      when 2
        window_size.times {|i|
          ch1 = na[i*2].real
          ch2 = na[(i*2)+1].real

          buf[i] = [ch1, ch2]
        }
      end

      buf
    end
  end
end
