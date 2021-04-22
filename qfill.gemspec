# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qfill/version'

Gem::Specification.new do |gem|
  gem.name          = 'qfill'
  gem.version       = Qfill::VERSION
  gem.authors       = ['Peter Boling']
  gem.email         = ['peter.boling@gmail.com']
  gem.description   = 'Advanced Queue Transformation'
  gem.summary       = 'You have a set of arrays that need to be turned into a different set of arrays
according to a potentially non-uniform set of rules.

Now you can easily turn this:

source_a # => [1,2,3,4]
source_b # => [5,6,7,8,9]

into this:

result_a # => [1,2]
result_b # => [3,5,7,9]
result_c # => [4,6,8]

by specifying filters for handling each transformation.
'
  gem.homepage      = 'https://github.com/pboling/qfill'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake', '~> 13'
  gem.add_development_dependency 'rspec', '~> 3'
end
