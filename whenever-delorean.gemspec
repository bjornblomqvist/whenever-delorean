# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "whenever-delorean"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Darwin"]
  s.date = "2013-04-22"
  s.description = "Helper for integration testing. It helps you trigger your whener runners."
  s.email = "darwin.git@marianna.se"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/whenever-delorean.rb",
    "spec/integration/whenever-delorean_spec.rb",
    "spec/spec_helper.rb",
    "spec/unit/whenever-delorean_spec.rb"
  ]
  s.homepage = "http://github.com/bjornblomqvist/whenever-delorean"
  s.licenses = ["LGPL"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Triggers your whener runners for you."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<delorean>, ["~> 2.1"])
      s.add_runtime_dependency(%q<whenever>, ["~> 0.8"])
      s.add_runtime_dependency(%q<parse-cron>, ["~> 0.1.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<ZenTest>, [">= 0"])
    else
      s.add_dependency(%q<delorean>, ["~> 2.1"])
      s.add_dependency(%q<whenever>, ["~> 0.8"])
      s.add_dependency(%q<parse-cron>, ["~> 0.1.2"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<ZenTest>, [">= 0"])
    end
  else
    s.add_dependency(%q<delorean>, ["~> 2.1"])
    s.add_dependency(%q<whenever>, ["~> 0.8"])
    s.add_dependency(%q<parse-cron>, ["~> 0.1.2"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<ZenTest>, [">= 0"])
  end
end
