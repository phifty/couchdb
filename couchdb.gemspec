# encoding: utf-8

Gem::Specification.new do |specification|
  specification.name              = "couchdb"
  specification.version           = "0.2.0"
  specification.date              = "2011-02-21"

  specification.authors           = [ "Philipp Brüll" ]
  specification.email             = "b.phifty@gmail.com"
  specification.homepage          = "http://github.com/phifty/couchdb"
  specification.rubyforge_project = "couchdb"

  specification.summary           = "A straight-forward client for CouchDB REST API."
  specification.description       = "A straight-forward client for CouchDB REST API. The resources exposed by the API are simply wrapped into classes."

  specification.has_rdoc          = true
  specification.files             = [ "README.rdoc", "LICENSE", "Rakefile" ] + Dir["lib/**/*"] + Dir["spec/**/*"]
  specification.extra_rdoc_files  = [ "README.rdoc" ]
  specification.require_path      = "lib"

  specification.test_files        = Dir["spec/**/*_spec.rb"]

  specification.add_dependency "transport", ">= 1.0.1"
  specification.add_development_dependency "rspec", ">= 2"
  specification.add_development_dependency "reek", ">= 1.2"
end
