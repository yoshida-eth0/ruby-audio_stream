lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "audio_stream/version"

Gem::Specification.new do |spec|
  spec.name          = "audio_stream"
  spec.version       = AudioStream::VERSION
  spec.authors       = ["Yoshida Tetsuya"]
  spec.email         = ["yoshida.eth0@gmail.com"]

  spec.summary       = %q{AudioStream is a Digital Audio Workstation for CLI}
  spec.description   = %q{AudioStream is a Digital Audio Workstation for CLI}
  spec.homepage      = "https://github.com/yoshida-eth0/ruby-audio_stream"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency "vdsp", ">= 1.6.0"
  spec.add_dependency "ruby-audio", ">= 1.6.1"
  spec.add_dependency "coreaudio", ">= 0.0.12"
  spec.add_dependency "ruby-fftw3", ">= 1.0.2"
  spec.add_dependency "rbplotly", ">= 0.1.2"
end
