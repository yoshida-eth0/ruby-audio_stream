require 'ruby-audio'
require 'coreaudio'
require 'numru/fftw3'
require 'rx'
require 'rbplotly'

require 'audio_stream/version'
require 'audio_stream/buffer'
require 'audio_stream/audio_input'
require 'audio_stream/audio_input_stream'
require 'audio_stream/audio_input_file'
require 'audio_stream/audio_input_device'
require 'audio_stream/audio_input_buffer'
require 'audio_stream/audio_input_sin'
require 'audio_stream/audio_bus'
require 'audio_stream/audio_output'
require 'audio_stream/audio_output_file'
require 'audio_stream/audio_output_device'
require 'audio_stream/fx'
require 'audio_stream/plot'

module AudioStream
  include NumRu
end
