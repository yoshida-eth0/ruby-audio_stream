require 'audio_stream/core_ext'
require 'optparse'

include AudioStream
include AudioStream::Fx


$input_stream = nil

op = OptionParser.new do |opt|
  opt.on('-f path', 'input file path') {|v|
    if File.exists?(v)
      $input_stream = AudioInput.file(v).stream
    else
      raise "No such input file: #{v}"
    end
  }
  opt.on('-d device', 'input device name') {|v|
    device = AudioInputDevice.devices.select{|d| d.name.downcase.include?(v.downcase)}.first
    if device
      $input_stream = device.stream
    else
      raise "No such input device: #{v}"
    end
  }

  begin
    opt.parse!(ARGV)

    if !$input_stream
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
    AudioInputDevice.devices.each {|d|
      puts "    #{d.name}"
    }

    exit
  end
end


$soundinfo = RubyAudio::SoundInfo.new(
  channels: 1,
  samplerate: 44100,
  format: RubyAudio::FORMAT_WAV|RubyAudio::FORMAT_PCM_16
)
