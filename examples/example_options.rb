require 'audio_stream'
require 'optparse'

include AudioStream
include AudioStream::Fx


$soundinfo = SoundInfo.new(
  channels: 2,
  samplerate: 44100,
  window_size: 1024,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)

$input_stream = nil

op = OptionParser.new do |opt|
  opt.on('-f path', 'input file path') {|v|
    if File.exists?(v)
      $input = AudioInput.file(v, soundinfo: $soundinfo)
    else
      raise "No such input file: #{v}"
    end
  }
  opt.on('-d device', 'input device name') {|v|
    device = AudioInputDevice.devices(soundinfo: $soundinfo).select{|d| d.name.downcase.include?(v.downcase)}.first
    if device
      $input = device
    else
      raise "No such input device: #{v}"
    end
  }

  begin
    opt.parse!(ARGV)

    if !$input
      raise ""
    end
  rescue => e
    if 0<e.message.length
      puts e.message
      puts
    end

    puts opt.help
    puts

    puts "Found input devices:"
    AudioInputDevice.devices(soundinfo: $soundinfo).each {|d|
      puts "    #{d.name}"
    }

    exit
  end
end
