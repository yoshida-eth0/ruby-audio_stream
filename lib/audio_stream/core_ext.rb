require 'audio_stream'

module Rx::Observable
  def fx(effector)
    #map(&effector.:process)
    map(&effector.method(:process))
  end

  def send_to(bus)
    bus.add(self)
    self
  end
end
