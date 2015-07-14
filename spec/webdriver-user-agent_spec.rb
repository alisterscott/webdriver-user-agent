require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'
require 'watir-webdriver'

CHROMEBROWSER_UICHROME_HEIGHT   = 72
CHROMEBROWSER_UI_MINIMUM_HEIGHT = 200
FIREFOXBROWSER_UICHROME_HEIGHT  = 79

describe "webdriver user agent" do
  after :each do
    @driver.quit if @driver
  end
  
  # window.innerWidth and window.innerHeight
  # do not accurately provide 
  # browser widths and heights
  # http://stackoverflow.com/a/8876069/1651458

  it "can create a new webdriver driver using firefox and iphone (portrait) by default" do
  	@driver = Webdriver::UserAgent.driver
  	expect(@driver.browser).to eq(:firefox)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(375) 
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(559 - FIREFOXBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and iphone 6 plus (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iphone6plus, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(736)
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(414 - CHROMEBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and iPad (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iPad, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPad'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(1024) 
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(704 - CHROMEBROWSER_UICHROME_HEIGHT)
  end
  
  it "can create a new webdriver driver using firefox and android phone (landscape)" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :android_phone, :orientation => :landscape)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Android'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(480) 
    
    # Chrome is apparently setting some kind of minimum height
    # As seen on Chrome v42 on OS X Yosimite
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(CHROMEBROWSER_UI_MINIMUM_HEIGHT)
    
  end

  it "can create a new webdriver driver using firefox and android tablet (portrait)" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :android_tablet, :orientation => :portrait)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Android'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(768)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(946 - CHROMEBROWSER_UICHROME_HEIGHT)
  end

   it "can create a new webdriver driver using firefox and random user agent" do
    @driver = Webdriver::UserAgent.driver(:agent => :random)
    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).not_to be_nil
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).not_to eq(320) 
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).not_to eq(356 - FIREFOXBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and random user agent" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :random)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).not_to be_nil
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).not_to eq(320) 
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).not_to eq(356 - CHROMEBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using an existing firefox profile" do
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.startup.homepage'] = "data:text/html,<title>hello</title>"
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :profile => profile)
    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(375) 
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(559 - FIREFOXBROWSER_UICHROME_HEIGHT)
    expect(@driver.title).to eq('hello')
  end
  
  it "can create a new webdriver driver using firefox and user-specified user agent" do
   @driver = Webdriver::UserAgent.driver(:user_agent_string => "Mozilla/4.0 (compatible; MSIE 5.5b1; Mac_PowerPC)")
   expect(@driver.browser).to eq(:firefox)
   expect(@driver.execute_script('return navigator.userAgent')).to include 'Mac_PowerPC'
   
   @browser = Watir::Browser.new @driver
   expect(@browser.url).to eq("about:blank") 
 end
  
  it "can create a new webdriver driver using firefox and user-specified viewport sizes (string or int)" do
    width = 800
    height = 600
    
    @driver = Webdriver::UserAgent.driver(:viewport_width => "#{width}", :viewport_height => height, :agent => :iphone6)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(800)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(600 - FIREFOXBROWSER_UICHROME_HEIGHT)

    @browser = Watir::Browser.new @driver
    expect(@browser.url).to eq("about:blank")
 end
  
  it "can create a new webdriver driver, handling for nonsense height and widths" do
    @driver = Webdriver::UserAgent.driver(:viewport_width => "abc", :agent => :iphone6)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(375) 
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(559 - FIREFOXBROWSER_UICHROME_HEIGHT)
   
    @browser = Watir::Browser.new @driver
    expect(@browser.url).to eq("about:blank")
 end

  it "can allow using selenium driver for watir browser" do
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait)
    @browser = Watir::Browser.new @driver
    expect(@browser.url).to eq("about:blank") 
  end

end