require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'

describe "webdriver user agent" do
  it "creates a new webdriver driver using firefox and iphone by default" do
  	driver = UserAgent.driver_for(:browser => :firefox, :agent => :iphone)
  	driver.browser.should == :firefox
  	driver.execute_script('return navigator.userAgent').should include 'iPhone'
  	driver.execute_script('return window.innerWidth').should == 320 
  	driver.execute_script('return window.innerHeight').should == 356
  	driver.quit
  end
end