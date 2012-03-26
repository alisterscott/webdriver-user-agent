# Webdriver::User::Agent

A helper gem to emulate populate device user agents and resolutions when using webdriver

## Installation

Add this line to your application's Gemfile:

    gem 'webdriver-user-agent'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install webdriver-user-agent

## Usage

provides a UserAgent.driver method to return a new web-driver with user agent and screen resolution mimicking a mobile device.

### Options

* :browser
	* :firefox (default)
	* :chrome
* :agent
	* :iphone (default)
	* :ipad
	* :android_phone
	* :android_tablet
* :orientation
	* :portrait (default)
	* :landscape

### Example using selenium-webdriver

	require 'selenium-webdriver'
	require 'webdriver-user-agent'
	driver = UserAgent.driver(:browser => :chrome, :agent => :iphone, :orientation => :landscape)
	driver.get 'http://tiffany.com'
	driver.current_url.should == 'http://m.tiffany.com/International.aspx'

### Example using watir-webdriver

	require 'watir-webdriver'
	require 'webdriver-user-agent'
	driver = UserAgent.driver(:browser => :chrome, :agent => :iphone, :orientation => :landscape)
	browser = Watir::Browser.new driver
	browser.goto 'tiffany.com'
	browser.url.should == 'http://m.tiffany.com/International.aspx'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
