module AudioStream
  class AudioInputSynth < Rx::Subject
    include AudioInput

    def initialize(synth, soundinfo:)
      super()

      @synth = synth

      @soundinfo = soundinfo
    end

    def name
      "Synth"
    end

    def each(&block)
      Enumerator.new do |y|
        loop {
          buf = @synth.next
          y << buf
        }
      end.each(&block)
    end
  end
end
