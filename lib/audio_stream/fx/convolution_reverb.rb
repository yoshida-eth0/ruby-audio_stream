module AudioStream
  module Fx
    class ConvolutionReverb
      include BangProcess

      def initialize(impulse, dry: 0.5, wet: 0.5)
        impulse_bufs = impulse.to_a
        @impulse_size = impulse_bufs.size
        @channels = impulse_bufs[0].channels
        @window_size = impulse_bufs[0].size
        @dry_gain = dry
        @wet_gain = wet

        zero_buf = RubyAudio::Buffer.float(@window_size, @channels)
        if @channels==1
          zero_buf.size.times {|i| zero_buf[i] = 0}
        else
          zero_buf.size.times {|i| zero_buf[i] = Array.new(@channels, 0)}
        end

        impulse_bufs = [zero_buf.clone] + impulse_bufs

        @impulse_ffts = []
        @impulse_size.times {|i|
          na = NArray.float(@channels, @window_size*2)

          buf1 = impulse_bufs[i]
          buf1 = buf1.to_a.flatten
          na[0...buf1.size] = buf1

          buf2 = impulse_bufs[i+1]
          buf2 = buf2.to_a.flatten
          na[buf1.size...(buf1.size+buf2.size)] = buf2

          @impulse_ffts << FFTW3.fft(na, FFTW3::FORWARD)
        }

        @impulse_max_gain =  @impulse_ffts.map{|c| c.real**2 + c.imag**2}.map(&:sum).max / @channels

        @wet_fft_matrix = Array.new(@impulse_size) {
          Array.new(@impulse_size, NArray.float(@channels, @window_size*2))
        }

        @prev_input = zero_buf.clone
      end

      def process!(input)
        if @window_size!=input.size
          raise "window size is not match: impulse.size=#{@window_size} input.size=#{input.size}"
        end
        if @channels!=input.channels
          raise "channels is not match: impulse.channels=#{@channels} input.channels=#{input.channels}"
        end

        # add current wet
        na = NArray.float(@channels, @window_size*2)

        prev_flat = @prev_input.to_a.flatten
        na[0...prev_flat.size] = prev_flat

        input_flat = input.to_a.flatten
        na[prev_flat.size...(prev_flat.size+input_flat.size)] = input_flat

        input_fft = FFTW3.fft(na, FFTW3::FORWARD)
        @wet_fft_matrix << @impulse_ffts.map {|impulse_fft|
          input_fft * impulse_fft
        }
        @wet_fft_matrix.shift
        @prev_input = input.clone

        # wet matrix sum
        wet_fft = NArray.float(@channels, @window_size*2)
        @impulse_size.times {|i|
          wet_fft += @wet_fft_matrix[i][@impulse_size-i-1]
        }

        # calc current wet
        wet_na = FFTW3.fft(wet_fft, FFTW3::BACKWARD)  / @impulse_max_gain * @wet_gain

        case @channels
        when 1
          @window_size.times {|i|
            dry = (input[i] || 0.0) * @dry_gain
            wet = wet_na[i].real
            input[i] = dry + wet
          }
        when 2
          @window_size.times {|i|
            # dry
            dry  = input[i] || [0.0, 0.0]
            dry1 = dry[0] * @dry_gain
            dry2 = dry[1] * @dry_gain

            # wet
            wet1 = wet_na[i*2].real
            wet2 = wet_na[(i*2)+1].real

            input[i] = [dry1 + wet1, dry2 + wet2]
          }
        end
      end
    end
  end
end
