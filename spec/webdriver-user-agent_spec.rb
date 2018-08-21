require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'
require 'watir'

CHROMEBROWSER_UICHROME_HEIGHT         = 114
CHROMEBROWSER_UICHROME_HEIGHT_TALL    = 41
CHROMEBROWSER_UI_MINIMUM_HEIGHT       = 158
FIREFOXBROWSER_UICHROME_HEIGHT        = 74
SAFARIBROWSER_UICHROME_HEIGHT         = 38

describe "webdriver user agent" do
  after :each do
    @browser.close if @browser rescue nil
    @driver.quit if @driver rescue nil
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
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(635 - FIREFOXBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using safari and iphone 6 plus, and landscape" do
  	@driver = Webdriver::UserAgent.driver(:browser => :safari, :agent => :iphone6plus, :orientation => :landscape)
  	expect(@driver.browser).to eq(:safari)

  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(736)
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(414 - SAFARIBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and iphone 6 plus (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :iphone6plus, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(736)
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(414 - CHROMEBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and iPad (landscape)" do
  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :ipad, :orientation => :landscape)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPad'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(1024)
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(698 - CHROMEBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using chrome and iPad Pro (portrait)" do
    # Testing the height will fail if your monitor is not tall enough.
    # For instance, a 15" MacBook Pro at default scaled resolution cannot be.
    # This will determine if your monitor is tall enough.
    # Optionally, you can override with an environment variable:
    # `I_HAVE_A_TALL_MONITOR=true rspec spec/this_file.rb`
    width = 800; height = 1302
    @driver = Webdriver::UserAgent.driver(:viewport_width => "#{width}", :viewport_height => height, :agent => :desktop)
    browser_max_height = @driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')
    @you_have_a_tall_monitor = (browser_max_height > (1302 - CHROMEBROWSER_UICHROME_HEIGHT))
    @you_have_a_tall_monitor = true if ("#{ENV['I_HAVE_A_TALL_MONITOR']}".downcase == 'true')
    @driver.quit if @driver
    # Back to your regularly scheduled test.

  	@driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :ipad_pro, :orientation => :portrait)
  	expect(@driver.browser).to eq(:chrome)
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'iPad'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(1024)

    # See above
    if @you_have_a_tall_monitor
  	   expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(1302 - CHROMEBROWSER_UICHROME_HEIGHT)
     end
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

  it "can create a new webdriver driver using chrome and android tablet (portrait)" do
    @driver = Webdriver::UserAgent.driver(:browser => :chrome, :agent => :android_tablet, :orientation => :portrait)
    expect(@driver.browser).to eq(:chrome)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Android'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(768)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(873 - CHROMEBROWSER_UICHROME_HEIGHT_TALL)
  end

  it "can create a new webdriver driver using firefox and desktop (landscape)" do
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :agent => :desktop, :orientation => :landscape)
    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'Mac OS X'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(1366)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(768 - FIREFOXBROWSER_UICHROME_HEIGHT)
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
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, options: options)

    expect(@driver.browser).to eq(:firefox)
    expect(@driver.execute_script('return navigator.userAgent')).to include 'iPhone'
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(375)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(635 - FIREFOXBROWSER_UICHROME_HEIGHT)
  end

  it "can create a new webdriver driver using firefox and user-specified user agent" do
   @driver = Webdriver::UserAgent.driver(:user_agent_string => "Mozilla/4.0 (compatible; MSIE 5.5b1; Mac_PowerPC)")
   expect(@driver.browser).to eq(:firefox)
   expect(@driver.execute_script('return navigator.userAgent')).to include 'Mac_PowerPC'

   @browser = Watir::Browser.new @driver
 end

  it "can create a new webdriver driver using firefox and user-specified viewport sizes (string or int)" do
    width = 800
    height = 600

    @driver = Webdriver::UserAgent.driver(:viewport_width => "#{width}", :viewport_height => height, :agent => :iphone6)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(800)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(600 - FIREFOXBROWSER_UICHROME_HEIGHT)
 end

  it "can create a new webdriver driver, handling for nonsense height and widths" do
    @driver = Webdriver::UserAgent.driver(:viewport_width => "abc", :agent => :iphone8)
    expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(375)
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(553 - FIREFOXBROWSER_UICHROME_HEIGHT)
 end

  it "can allow using selenium driver for watir browser" do
    @driver = Webdriver::UserAgent.driver(:browser => :firefox, :agent => :iphone, :orientation => :portrait)
    @browser = Watir::Browser.new @driver
    expect(@browser).to be_a(Watir::Browser)
    expect(@browser.url).to be_a(String)
  end

end
