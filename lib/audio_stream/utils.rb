module AudioStream
  module Utils

    def self.panning(pan)
      cp = cross_panning(pan)

      {
        l_gain: (cp[:l_gain] + cp[:lr_gain]) / cp[:normalize],
        r_gain: (cp[:r_gain] + cp[:rl_gain]) / cp[:normalize]
      }
    end

    def self.cross_panning(pan)
      if pan<-1.0
        pan = -1.0
      elsif 1.0<pan
        pan = 1.0
      end

      l_gain = 1.0 - pan
      lr_gain = 0.0
      if 1.0<l_gain
        lr_gain = l_gain - 1.0
        l_gain = 1.0
      end

      r_gain = 1.0 + pan
      rl_gain = 0.0
      if 1.0<r_gain
        rl_gain = r_gain - 1.0
        r_gain = 1.0
      end

      normalize = [1.0 - pan, 1.0 + pan].max

      {
        l_gain: l_gain,
        lr_gain: lr_gain,
        r_gain: r_gain,
        rl_gain: rl_gain,
        normalize: normalize
      }
    end
  end
end
