module AudioStream
  module Fx
    class LowPassFilter
      include BangProcess

      def initialize(soundinfo, freq:, resonance: 0.0, smooth: 100, window: nil)
        @samplerate = soundinfo.samplerate.to_f
        @freq = freq
        @resonance = resonance
        @smooth = smooth
        @window = window || HanningWindow.new
      end

      def process!(input)
        window_size = input.size
        channels = input.channels

        # fft
        @window.process!(input)
        na = NArray.float(channels, window_size)
        na[0...na.size] = input.to_a.flatten
        fft = FFTW3.fft(na, FFTW3::FORWARD) / na.length

        freq_rate = @samplerate / window_size
        reso_i = (@freq / freq_rate).to_i
        smooth_len = (@smooth / freq_rate).to_i * channels

        reso_s = reso_i - smooth_len
        if reso_s<0
          reso_s = 0
        end
        reso_e = reso_i + smooth_len
        if window_size<reso_e
          reso_e = window_size
        end

        smooth_len = reso_i - reso_s
        smooth_len.times {|i|
          j = reso_s + i
          channels.times {|l|
            fft_i = j * channels + l
            fft[fft_i] += @resonance * fft[fft_i] * (i.to_f / smooth_len)
          }
        }

        smooth_len = reso_e - reso_i
        smooth_len.times {|i|
          j = reso_i + i
          k = smooth_len - i
          channels.times {|l|
            fft_i = j * channels + l
            fft[fft_i] += @resonance * fft[fft_i] * (k.to_f / smooth_len)
            fft[fft_i] *= k.to_f / smooth_len
          }
        }

        fft[reso_e...fft.size] = 0i

        wet_na = FFTW3.fft(fft, FFTW3::BACKWARD)

        case channels
        when 1
          window_size.times {|i|
            input[i] = wet_na[i].real
          }
        when 2
          window_size.times {|i|
            wet1 = wet_na[i*2].real
            wet2 = wet_na[(i*2)+1].real

            input[i] = [wet1, wet2]
          }
        end
      end
    end
  end

  NArray.include Enumerable
end
