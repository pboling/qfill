# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in qfill.gemspec
gemspec

ruby_version = Gem::Version.new(RUBY_VERSION)

gem 'yard', '~> 0.9.24', require: false

### deps for rdoc.info
group :documentation do
  gem 'github-markup', platform: :mri
  gem 'redcarpet', platform: :mri
end

group :development, :test do
  if ruby_version >= Gem::Version.new('2.4')
    # No need to run byebug on earlier versions
    gem 'byebug', platform: :mri
  end

  if ruby_version >= Gem::Version.new('2.7')
    # No need to run rubocop or simplecov on earlier versions
    gem 'rubocop', '~> 1.9', platform: :mri
    gem 'rubocop-md', platform: :mri
    gem 'rubocop-packaging', platform: :mri
    gem 'rubocop-performance', platform: :mri
    gem 'rubocop-rake', platform: :mri
    gem 'rubocop-rspec', platform: :mri

    gem 'simplecov', '~> 0.21', platform: :mri
  end
end
