require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'
require 'watir-webdriver'

describe "webdriver user agent" do
  after :each do
    @driver.quit if @driver
  end

  it "can create a new webdriver driver using firefox and iphone (portrait) by default" do
  	@driver = UserAgent.driver
  	@driver.browser.should == :firefox
  	@driver.execute_script('return navigator.userAgent').should include 'iPhone'
  	@driver.execute_script('return window.innerWidth').should == 320 
  	@driver.execute_script('return window.innerHeight').should == 356
  end

  it "can create a new webdriver driver using chrome and iPad (landscape)" do
  	@driver = UserAgent.driver(:browser => :chrome, :agent => :iPad, :orientation => :landscape)
  	@driver.browser.should == :chrome
  	@driver.execute_script('return navigator.userAgent').should include 'iPad'
  	@driver.execute_script('return window.innerWidth').should == 1024 
  	@driver.execute_script('return window.innerHeight').should == 690
  end
  
  it "can create a new webdriver driver using firefox and android phone (landscape)" do
    @driver = UserAgent.driver(:browser => :chrome, :agent => :android_phone, :orientation => :landscape)
    @driver.browser.should == :chrome
    @driver.execute_script('return navigator.userAgent').should include 'Android'
    @driver.execute_script('return window.innerWidth').should == 480 
    @driver.execute_script('return window.innerHeight').should == 196
  end

  it "can create a new webdriver driver using firefox and android tablet (portrait)" do
    @driver = UserAgent.driver(:browser => :chrome, :agent => :android_tablet, :orientation => :portrait)
    @driver.browser.should == :chrome
    @driver.execute_script('return navigator.userAgent').should include 'Android'
    @driver.execute_script('return window.innerWidth').should == 768
    @driver.execute_script('return window.innerHeight').should == 946
  end

   it "can create a new webdriver driver using firefox and random user agent" do
    @driver = UserAgent.driver(:agent => :random)
    @driver.browser.should == :firefox
    @driver.execute_script('return navigator.userAgent').should_not be_nil
    @driver.execute_script('return window.innerWidth').should_not == 320 
    @driver.execute_script('return window.innerHeight').should_not == 356
  end

  it "can create a new webdriver driver using chrome and random user agent" do
    @driver = UserAgent.driver(:browser => :chrome, :agent => :random)
    @driver.browser.should == :chrome
    @driver.execute_script('return navigator.userAgent').should_not be_nil
    @driver.execute_script('return window.innerWidth').should_not == 320 
    @driver.execute_script('return window.innerHeight').should_not == 356
  end

  it "can create a new webdriver driver using an existing firefox profile" do
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.startup.homepage'] = "data:text/html,<title>hello</title>"
    @driver = UserAgent.driver(:browser => :firefox, :profile => profile)
    @driver.browser.should == :firefox
    @driver.execute_script('return navigator.userAgent').should include 'iPhone'
    @driver.execute_script('return window.innerWidth').should == 320 
    @driver.execute_script('return window.innerHeight').should == 356
    @driver.title.should == 'hello'
  end

  it "can allow using selenium driver for watir browser" do
    @driver = UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait)
    @browser = Watir::Browser.new @driver
    @browser.url.should == "about:blank" 
  end




end