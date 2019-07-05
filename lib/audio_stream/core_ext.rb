require 'audio_stream'

module Rx::Observable
  def fx(effector)
    #map(&effector.:process)
    map(&effector.method(:process))
  end

  def send_to(bus, gain: nil, pan: nil)
    bus.add(self, gain: gain, pan: pan)
    self
  end
end
