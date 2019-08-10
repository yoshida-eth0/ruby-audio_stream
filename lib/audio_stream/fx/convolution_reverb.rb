module AudioStream
  module Fx
    class ConvolutionReverb
      def initialize(impulse, dry: 0.5, wet: 0.5)
        impulse_bufs = impulse.to_a
        @impulse_size = impulse_bufs.size
        @channels = impulse_bufs[0].channels
        @window_size = impulse_bufs[0].window_size
        @dry_gain = dry
        @wet_gain = wet

        zero_buf = Buffer.create(@window_size, @channels)
        impulse_bufs = [zero_buf.clone] + impulse_bufs

        @impulse_ffts = []
        @impulse_size.times {|i|
          na = NArray.float(@channels, @window_size*2)
          impulse_bufs[i].to_float_na(na, 0)
          impulse_bufs[i+1].to_float_na(na, @window_size)
          @impulse_ffts << FFTW3.fft(na, FFTW3::FORWARD) / na.length
        }

        @impulse_max_gain =  @impulse_ffts.map{|c| c.real**2 + c.imag**2}.map(&:sum).max / @channels

        @wet_ffts = RingBuffer.new(@impulse_size) {
          Array.new(@impulse_size, NArray.float(@channels, @window_size*2))
        }

        @prev_input = zero_buf.clone
      end

      def process(input)
        if @window_size!=input.window_size
          raise "window size is not match: impulse.size=#{@window_size} input.size=#{input.window_size}"
        end
        if @channels!=input.channels
          raise "channels is not match: impulse.channels=#{@channels} input.channels=#{input.channels}"
        end

        # current dry to wet
        na = NArray.float(@channels, @window_size*2)
        @prev_input.to_float_na(na, 0)
        input.to_float_na(na, @window_size)

        input_fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

        @wet_ffts.current = @impulse_ffts.map {|impulse_fft|
          input_fft * impulse_fft
        }
        @wet_ffts.rotate
        @prev_input = input.clone

        # calc wet matrix sum
        wet_fft = NArray.complex(@channels, @window_size*2)
        @wet_ffts.each_with_index {|wet, i|
          wet_fft += wet[@impulse_size-i-1]
        }

        wet_na = FFTW3.fft(wet_fft, FFTW3::BACKWARD)[(@channels*@window_size)...(@channels*@window_size*2)] * (@wet_gain / @impulse_max_gain)

        # current dry + wet matrix sum
        src0 = input.streams[0]
        src1 = input.streams[1]

        case @channels
        when 1
          output = Buffer.create_mono(@window_size)
          dst0 = output.streams[0]

          @window_size.times {|i|
            dry = src0[i] * @dry_gain
            wet = wet_na[i].real
            dst0[i] = dry + wet
          }
        when 2
          output = Buffer.create_stereo(@window_size)
          dst0 = output.streams[0]
          dst1 = output.streams[1]

          @window_size.times {|i|
            # dry
            dry0 = src0[i] * @dry_gain
            dry1 = src1[i] * @dry_gain

            # wet
            wet0 = wet_na[i*2].real
            wet1 = wet_na[(i*2)+1].real

            dst0[i] = dry0 + wet0
            dst1[i] = dry1 + wet1
          }
        end

        output
      end
    end
  end
end
