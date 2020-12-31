Gem::Specification.new do |s|
  s.name = 'crossing'
  s.executables << 'crossing'
  s.license       = 'MIT'
  s.version       = '0.0.0'
  s.author        = ['John Ulick', 'Jonny Sywulak', 'Keith Monihen', 'Stelligent']
  s.email         = 'info@stelligent.com'
  s.homepage      = 'https://github.com/stelligent/crossing'
  s.summary       = 'Utility for storing objects in S3 while taking advantage ' \
                    'of client side envelope encryption with KMS.'
  s.description   = <<DESC
  The native AWS command line does not have an easy way to upload encrypted files
  to S3. This utility allows you to do client side encrypted uploads to S3 from the
  command line, which is useful for uploads from your CI system to docker
  containers.
DESC
  s.files = ['lib/crossing.rb']
  s.require_paths << 'lib'
  s.require_paths << 'bin'
  s.required_ruby_version = '>= 2.5'

  s.add_development_dependency('cucumber')
  s.add_development_dependency('nyan-cat-formatter')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubygems-tasks')
  s.add_development_dependency('simplecov')

  s.add_runtime_dependency('aws-sdk-s3')
  s.add_runtime_dependency('trollop')
end
