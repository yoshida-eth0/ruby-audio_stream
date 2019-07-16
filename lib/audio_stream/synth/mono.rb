module AudioStream
  module Synth
    class Mono

      attr_reader :oscs
      attr_reader :amp
      attr_reader :processor

      attr_reader :quality
      attr_reader :soundinfo

      attr_reader :glide
      attr_accessor :pitch_bend

      # @param oscs [Osc] oscillator
      # @param amp [Amp] amplifier
      # @param soundinfo [SoundInfo]
      def initialize(oscs:, amp:, glide: 0.1, quality: Quality::LOW, soundinfo:)
        @oscs = [oscs].flatten.compact
        @amp = amp

        @quality = quality
        @soundinfo = soundinfo

        @processor = Processor.create(quality)
        @note_nums = []
        @note = nil
        @glide = Modulation::Glide.new(time: glide)
        @pitch_bend = 0.0
      end

      def next
        if @note
          buf = @note.next

          # delete released notes
          if @note.released?
            @note = nil
          end

          buf
        else
          Buffer.float(@soundinfo.window_size, @soundinfo.channels)
        end
      end

      def note_on(tune)
        # Note Off
        note_off(tune)

        if @note && @note.note_on?
          # Glide
          @glide.target = tune.note_num
        else
          # Note On
          @note = Note.new(self, tune)
          @glide.base = tune.note_num
        end
        @note_nums << tune.note_num        
      end

      def note_off(tune)
        # Note Off
        @note_nums.delete_if {|note_num| note_num==tune.note_num}

        if @note
          if @note_nums.length==0
            # Note Off
            @note.note_off!
          else
            # Glide
            @glide.target = @note_nums.last
          end
        end
      end
    end
  end
end
