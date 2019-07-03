module AudioStream
  class Buffer < RubyAudio::Buffer
    def plot(soundinfo=nil)
      Plot.new(self, soundinfo)
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
