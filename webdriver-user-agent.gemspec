# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Alister Scott", "Jeff Morgan", "Sandeep Singh", "Sam Nissen"]
  gem.email         = ["alister.scott@gmail.com", "jeff.morgan@leandog.com", "sandeepnagra@gmail.com", "scnissen@gmail.com"]
  gem.description   = %q{A helper gem to emulate populate device user agents and resolutions when using webdriver}
  gem.summary       = %q{A helper gem to emulate populate device user agents and resolutions when using webdriver}
  gem.homepage      = "https://github.com/alisterscott/webdriver-user-agent"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "webdriver-user-agent"
  gem.require_paths = ["lib"]
  gem.version       = "7.8"
  gem.requirements << 'chromedriver, v2.20'
  # chromedriver v2.19 causes
    # Selenium::WebDriver::Error::NoSuchDriverError: no such session errors
  gem.add_dependency 'selenium-webdriver', '>= 3.4.0'
  gem.add_dependency 'os'
  gem.add_dependency 'facets'
  gem.add_dependency 'json'
  gem.add_dependency 'psych'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'watir'
  gem.add_development_dependency 'webdrivers'
end
