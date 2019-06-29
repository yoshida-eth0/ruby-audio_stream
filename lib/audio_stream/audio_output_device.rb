module AudioStream
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
end
