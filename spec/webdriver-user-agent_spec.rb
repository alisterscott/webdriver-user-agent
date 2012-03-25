require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'

describe "webdriver user agent" do
  it "creates a new webdriver driver using firefox and iphone by default" do
  	driver = UserAgent.driver_for(:browser => :firefox, :agent => :iphone)
  	driver.browser.should == :firefox
  	driver.execute_script('return navigator.userAgent').should == "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5"
  	driver.execute_script('return window.innerWidth').should == 320 
  	driver.execute_script('return window.innerHeight').should == 356
  end
end