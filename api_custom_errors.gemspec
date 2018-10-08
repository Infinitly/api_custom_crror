lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_custom_errors/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_custom_errors'
  spec.version       = ApiCustomErrors::VERSION
  spec.authors       = ['Jonathan PHILIPPE']
  spec.email         = ['pretrine@gmail.com']

  spec.summary       = 'Api Custom Errors'
  spec.description   = spec.summary
  spec.license       = 'MIT'

  spec.homepage      = 'https://github.com/infinitly/api_custom_errors'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  unless spec.respond_to?(:metadata)
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # spec.metadata['allowed_push_host'] = ''
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'rails', '~> 5.0'
end
