# frozen_string_literal: true

require_relative 'lib/legion/extensions/metacognition/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-metacognition'
  spec.version       = Legion::Extensions::Metacognition::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Metacognition'
  spec.description   = 'Second-order self-model assembly for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-metacognition'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-metacognition'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-metacognition'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-metacognition'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-metacognition/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-metacognition.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end
