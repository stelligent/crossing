require 'rake'

# rubocop:disable Style/SpaceAroundOperators
# rubocop:disable Lint/UselessAssignment
# rubocop:disable Style/ExtraSpacing
spec = Gem::Specification.new do |s|
  s.name          = 'crossing'
  s.executables  << 'crossing'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.author        = ['John Ulick', 'Jonny Sywulak', 'Keith Monihen', 'Stelligent']
  s.email         = 'info@stelligent.com'
  s.homepage      = 'http://www.stelligent.com'
  s.summary       = 'Utility for storing objects in S3 while taking advantage ' \
                    'of client side envelope encryption with KMS.'
  s.description   = <<EOS
  The native AWS command line does not have an easy way to upload encrypted files
  to S3. The Ruby SDK has a way to do this, but not everyone wants to use it.
  This utility allows you to do client side encrypted uploads to S3 from the
  command line, which is useful for uploads from your CI system to docker
  containers.
EOS
  s.files       = ['lib/crossing.rb']
  s.require_paths << 'lib'
  s.require_paths << 'bin'
  s.required_ruby_version = '>= 2.2'

  s.add_development_dependency('cucumber')
  s.add_development_dependency('nyan-cat-formatter')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubygems-tasks')
  s.add_development_dependency('simplecov')

  s.add_runtime_dependency('aws-sdk', '~> 2')
  s.add_runtime_dependency('trollop', '=2.1.2')
end
# rubocop:enable Style/SpaceAroundOperators
# rubocop:enable Lint/UselessAssignment
# rubocop:enable Style/ExtraSpacing
