# frozen_string_literal: true

require_relative "lib/LittleJohn/version"

Gem::Specification.new do |spec|
  spec.name          = "LittleJohn"
  spec.version       = LittleJohn::VERSION
  spec.authors       = ["Dan James"]
  spec.email         = ["dan@danarchy.me"]

  spec.summary       = "A Ruby Automation Framework"
  spec.description   = <<EOF
This automation framework is the culmination of my 2 years of work developing
an application which automated my stock trading activity on Robinhood.

That original application streamed stock data from Robinhood's REST-API into
MongoDB, aggregated that data into candlestick data over various time intervals,
ran simulations on that historical data to identify ideal trading positions,
then automatically performed live-trading during open market hours.

The program progressed from a series of basic Ruby scripts, to more complete
object-oriented code, and ultimately was redesigned through the development of
this framework you see here.

The primary modules of code include:
- a MongoDB wrapper to ensure connectivity and safe error handling
- a Collection/Model framework akin to ActiveRecord interacting with MongoDB
- an HTTP request class to make JSON-API requests out to external APIs
- an SMTP email sender
- a ThreadHandler to control multi-threading through use of Ruby lambdas
- a Daemon to fork the application with Docker container support

Though work still remains to be done such as proper logging, documentation, code
cleanup, and probably additional features, I am releasing this framework publicly
so that I can begin updating my other Open Source projects to take advantage of
what I have built here.

This is released under the MIT Open Source License to be used, copied, and modified
as people wish. However, since it is also a display of my personal skill development
and work, I currently do not plan to accept outside contributions. Pull-reqeusts are
still welcome if you wish to fix/implement code and share it with others, but it will
likely not be committed into the base repository.
EOF

  spec.homepage      = "https://github.com/danarchy85/LittleJohn"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.14"

  spec.add_dependency "mongo", "2.18"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
