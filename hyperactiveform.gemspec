# frozen_string_literal: true

require_relative "lib/hyper_active_form/version"

Gem::Specification.new do |spec|
  spec.name = "hyperactiveform"
  spec.version = HyperActiveForm::VERSION
  spec.authors = ["Adrien Siami"]
  spec.email = ["adrien@siami.fr"]

  spec.summary = "Simple form objects for Rails"
  spec.description = "Encapsulate form logic and validations in a simple object"
  spec.homepage = "https://github.com/Intrepidd/hyperactiveform"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/Intrepidd/hyperactiveform/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "yard"
end
