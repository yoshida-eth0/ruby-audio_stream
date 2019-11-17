module AudioStream
  module Fx

    module MultiAudioInputtable
      def audio_input_keys
        @audio_input_keys ||= Set.new
      end

      def regist_audio_input(key)
        audio_input_keys << key
      end
    end
  end
end
