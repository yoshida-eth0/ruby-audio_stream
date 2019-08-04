module AudioStream
  class Buffer < RubyAudio::Buffer
    def stereo(&block)
      case self.channels
      when 1
        lazy.map {|f|
          [f, f]
        }.each(&block)
      when 2
        self.each(&block)
      end
    end

    def mono(&block)
      case self.channels
      when 1
        self.each(&block)
      when 2
        lazy.map {|fa|
          (fa[0] + fa[1]) / 2.0
        }.each(&block)
      end
    end

    def +(other)
      self.class.merge(self, other)
    end

    def self.merge(*buffers)
      buffers = buffers.flatten

      if buffers.length==0
        raise Error, "argument is empty"
      elsif buffers.length==1
        return buffers.first.clone
      end

      buffers.each {|buf|
        unless Buffer===buf
          raise Error, "argument is not Buffer: #{buf}"
        end
        if buffers[0].size!=buf.size
          i = buffers.index(buf)
          raise Error, "Buffer.size is not match: buffers[0].size=#{buffers[0].size} buffers[#{i}].size=#{buf.size}"
        end
      }

      channels = buffers.map(&:channels).max
      window_size = buffers[0].size

      result = Buffer.float(window_size, channels)

      case channels
      when 1
        buffers.each {|buf|
          buf.mono.each_with_index {|f, i|
            result[i] += f
          }
        }
      when 2
        buffers.each {|buf|
          buf.stereo.each_with_index {|fa1, i|
            fa2 = result[i]
            result[i] = [fa1[0] + fa2[0], fa1[1] + fa2[1]]
          }
        }
      end

      result
    end

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

    [:short, :int, :float, :double].each do |type|
      eval "def self.#{type}(frames, channels=1)
              buf = self.new(:#{type}, frames, channels)
              buf.real_size = buf.size
              buf
            end"
    end
  end
end
