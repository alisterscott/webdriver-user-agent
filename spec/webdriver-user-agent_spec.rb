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
  	@driver = Webdriver::UserAgent.driver
  	expect(@driver.browser).to eq(:firefox)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return window.innerWidth')).to eq(375) 
  	expect(@driver.execute_script('return window.innerHeight')).to eq(559)
  end

  it "can create a new webdriver driver using chrome and iphone 6 plus (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iphone6plus, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return window.innerWidth')).to eq(736) 
  	expect(@driver.execute_script('return window.innerHeight')).to eq(414)
  end

  it "can create a new webdriver driver using chrome and iPad (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iPad, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPad'
  	expect(@driver.execute_script('return window.innerWidth')).to eq(1024) 
  	expect(@driver.execute_script('return window.innerHeight')).to eq(690)
  end
  
  it "can create a new webdriver driver using firefox and android phone (landscape)" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :android_phone, :orientation => :landscape)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Android'
    expect(@driver.execute_script('return window.innerWidth')).to eq(480) 
    expect(@driver.execute_script('return window.innerHeight')).to eq(196)
  end

  it "can create a new webdriver driver using firefox and android tablet (portrait)" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :android_tablet, :orientation => :portrait)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Android'
    expect(@driver.execute_script('return window.innerWidth')).to eq(768)
    expect(@driver.execute_script('return window.innerHeight')).to eq(946)
  end

   it "can create a new webdriver driver using firefox and random user agent" do
    @driver = Webdriver::UserAgent.driver(:agent => :random)
    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).not_to be_nil
    expect(@driver.execute_script('return window.innerWidth')).not_to eq(320) 
    expect(@driver.execute_script('return window.innerHeight')).not_to eq(356)
  end

  it "can create a new webdriver driver using chrome and random user agent" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :random)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).not_to be_nil
    expect(@driver.execute_script('return window.innerWidth')).not_to eq(320) 
    expect(@driver.execute_script('return window.innerHeight')).not_to eq(356)
  end

  it "can create a new webdriver driver using an existing firefox profile" do
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.startup.homepage'] = "data:text/html,<title>hello</title>"
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :profile => profile)
    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
    expect(@driver.execute_script('return window.innerWidth')).to eq(375) 
    expect(@driver.execute_script('return window.innerHeight')).to eq(559)
    expect(@driver.title).to eq('hello')
  end

  it "can allow using selenium driver for watir browser" do
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait)
    @browser = Watir::Browser.new @driver
    expect(@browser.url).to eq("about:blank") 
  end




end