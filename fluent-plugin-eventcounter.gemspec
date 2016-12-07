# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-eventcounter"
  gem.version     = "0.0.6"
  gem.authors     = ["Sean Dick", "Vijay Ramesh"]
  gem.email       = ["sean@seandick.net", "vijay@change.org"]
  gem.homepage    = "https://github.com/change/fluent-plugin-eventcounter"
  gem.summary     = %q{Fluentd plugin to count occurences of values in a field and emit them or write them to redis}
  gem.description = %q{Fluentd plugin to count occurences of values in a field and emit them or write them to redis}
  gem.license     = "MIT"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "redis"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "test-unit", "~> 3.1.0"
  gem.add_development_dependency "appraisal", "~> 2.1.0"
end
