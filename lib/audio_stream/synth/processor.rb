require 'audio_stream/synth/processor/low'
require 'audio_stream/synth/processor/high'

module AudioStream
  module Synth
    module Processor
      def self.create(quality)
        const_get(quality, false).new
      end
    end
  end
end
