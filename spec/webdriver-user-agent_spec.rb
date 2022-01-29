require 'rspec'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'webdriver-user-agent'
require 'selenium-webdriver'
require 'watir'
require 'webdrivers'

CHROMEBROWSER_UICHROME_HEIGHT         = 124
CHROMEBROWSER_UICHROME_HEIGHT_TALL    = 50
CHROMEBROWSER_UI_MINIMUM_HEIGHT       = 289
FIREFOXBROWSER_UICHROME_HEIGHT        = 74
FIREFOXBROWSER_MINIMUM_WIDTH          = 450
SAFARIBROWSER_UICHROME_HEIGHT         = 38
SIZE_FUDGE_FACTOR                     = 0.05

RSpec.shared_examples "browser driver" do
  it "creates the browser driver" do
    expect("#{driver.browser}").to match(/#{Regexp.quote(browser.to_s)}/i)
  end

  it "matches the agent partial" do
    expect(driver.execute_script(agent_script)).to include agent_match
  end
end

RSpec.shared_examples "random browser driver" do
  it "creates the browser driver" do
    expect("#{driver.browser}").to match(/#{Regexp.quote(browser.to_s)}/i)
  end

  it "matches the agent partial" do
    expect(driver.execute_script(agent_script)).not_to be_nil
  end
end

RSpec.shared_examples "firefox size" do
  it "matches the expected width" do
    width_expectation = device.dig(orientation.downcase.to_sym, :width)
    width_expectation = FIREFOXBROWSER_MINIMUM_WIDTH if width_expectation < FIREFOXBROWSER_MINIMUM_WIDTH
    width_expectation_fudge = width_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(width_script)).to be_within(width_expectation_fudge).of(width_expectation)
  end

  it "matches the expected height" do
    height_expectation = device.dig(orientation.downcase.to_sym, :height) - FIREFOXBROWSER_UICHROME_HEIGHT
    height_expectation_fudge = height_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(height_script)).to be_within(height_expectation_fudge).of(height_expectation)
  end
end

RSpec.shared_examples "safari size" do
  it "matches the expected width" do
    width_expectation = device.dig(orientation.downcase.to_sym, :width)
    width_expectation_fudge = width_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(width_script)).to be_within(width_expectation_fudge).of(width_expectation)
  end

  it "matches the expected height" do
    height_expectation = device.dig(orientation.downcase.to_sym, :height) - SAFARIBROWSER_UICHROME_HEIGHT
    height_expectation_fudge = height_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(height_script)).to be_within(height_expectation_fudge).of(height_expectation)
  end
end

RSpec.shared_examples "chrome size" do
  it "matches the expected width" do
    width_expectation = device.dig(orientation.downcase.to_sym, :width)
    width_expectation_fudge = width_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(width_script)).to be_within(width_expectation_fudge).of(width_expectation)
  end

  it "matches the expected height" do
    height_expectation = device.dig(orientation.downcase.to_sym, :height) - CHROMEBROWSER_UICHROME_HEIGHT
    height_expectation_fudge = height_expectation.to_f * SIZE_FUDGE_FACTOR
    expect(driver.execute_script(height_script)).to be_within(height_expectation_fudge).of(height_expectation)
  end
end

describe "webdriver user agent" do
  let(:devices) { Webdriver::UserAgent.devices }
  let(:agent_script) { 'return navigator.userAgent' }
  let(:width_script) { 'return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)' }
  let(:height_script) { 'return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)' }

  after :each do
    driver.quit if defined?(driver) rescue Selenium::WebDriver::Error::SessionNotCreatedError
    browser.close if defined?(browser) && browser&.is_a?(Watir::Browser)
    `defaults delete com.apple.SafariTechnologyPreview CustomUserAgent >/dev/null 2>/dev/null`
    `defaults delete com.apple.SafariTechnologyPreview AppleLanguages >/dev/null 2>/dev/null`
    `defaults delete com.apple.Safari CustomUserAgent >/dev/null 2>/dev/null`
    `defaults delete com.apple.Safari AppleLanguages >/dev/null 2>/dev/null`
    sleep(0.5) # Safari needs time to shutdown
  end

  # window.innerWidth and window.innerHeight
  # do not accurately provide
  # browser widths and heights
  # http://stackoverflow.com/a/8876069/1651458

  context "standard browser, agent or orientation set" do
    let(:device) { devices[:iphone] }
    let(:driver) { Webdriver::UserAgent.driver }
    let(:browser) { "firefox" }
    let(:orientation) { :portrait }
    let(:agent_match) { 'iPhone' }

    it_behaves_like "browser driver"
    it_behaves_like "firefox size"
  end
  
  context "device, browser, orientation, agent are all symbols" do
    let(:device) { devices[:iphone] }
    let(:device_key) { :iphone }
    let(:browser) { :firefox }
    let(:orientation) { :landscape }
    let(:driver) { Webdriver::UserAgent.driver(
      browser: browser,
      agent: device_key,
      orientation: orientation) }
    let(:agent_match) { 'iPhone' }
  
    it_behaves_like "browser driver"
    it_behaves_like "firefox size"
  end
  
  context "browser is a symbol; device, orientation, agent are all strings" do
    let(:device) { devices[:iphone] }
    let(:device_key) { "iPhone" }
    let(:browser) { :firefox }
    let(:orientation) { "Portrait" }
    let(:driver) { Webdriver::UserAgent.driver(
      browser: browser,
      agent: device_key,
      orientation: orientation) }
    let(:agent_match) { 'iPhone' }
  
    it_behaves_like "browser driver"
    it_behaves_like "firefox size"
  end

  context "Safari browser, iPhone 11 Pro Max agent, landscape orientation" do
    let(:device) { devices[:iphone11promax] }
    let(:orientation) { :landscape }
    let(:driver) do
      # --- On Safari ---
      # Safari is a mess. We do our best to test it, but
      # it is too unreliable. The gem will still try to provide
      # these features for the time being. 
      # If you are a subject matter expert, please
      # get in touch. - Sam

      Webdriver::UserAgent.driver(
        browser: :safari,
        agent: :iphone11promax,
        orientation: orientation
      )
    end
    let(:browser) { "safari" }
    let(:orientation) { :landscape }
    let(:agent_match) { 'iPhone' }

    # pending("a stable, documented way to programmatically change Safari details") { it_behaves_like "browser driver" }
    # But there doesn't seem to be any way for RSpec to handle the above?
    # `it_behaves_like` isn't available inside `pending`, but `pending` isn't available at 
    # the `context` level.
    it_behaves_like "safari size"
  end

  context "Safari browser, iPhone 6 Plus agent, landscape orientation" do
    let(:device) { devices[:iphone6plus] }
    let(:orientation) { :landscape }
    let(:driver) do
      Webdriver::UserAgent.driver(
        browser: :safari,
        agent: :iphone6plus,
        orientation: orientation
      )
    end
    let(:browser) { "safari" }
    let(:agent_match) { 'iPhone' }
    
    # pending("a stable, documented way to programmatically change Safari details") { it_behaves_like "browser driver" }
    # But there doesn't seem to be any way for RSpec to handle the above?
    # `it_behaves_like` isn't available inside `pending`, but `pending` isn't available at 
    # the `context` level.
    it_behaves_like "safari size"
  end

  context "Chrome browser, iPhone XS agent, landscape orientation" do
    let(:device_key) { :iphonexs }
    let(:device) { devices[device_key] }
    let(:orientation) { :landscape }
    let(:driver) do
      Webdriver::UserAgent.driver(
        browser: :chrome,
        agent: device_key,
        orientation: orientation
      )
    end
    let(:browser) { "chrome" }
    let(:agent_match) { 'iPhone' }

    it_behaves_like "browser driver"
    it_behaves_like "chrome size"
  end

  context "Chrome browser, iPhone XS agent, landscape orientation" do
    let(:device_key) { :iphone6 }
    let(:device) { devices[device_key] }
    let(:orientation) { :landscape }
    let(:driver) do
      Webdriver::UserAgent.driver(
        browser: :chrome,
        agent: device_key,
        orientation: orientation
      )
    end
    let(:browser) { "chrome" }
    let(:agent_match) { 'Mac OS' }

    it_behaves_like "browser driver"
    it_behaves_like "chrome size"
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
  	expect(@driver.execute_script('return navigator.userAgent')).to include 'Mac OS'
  	expect(@driver.execute_script('return Math.max(document.documentElement.clientWidth, window.innerWidth || 0)')).to eq(1024)

    # See above
    if @you_have_a_tall_monitor
      expect(@driver.execute_script('return Math.max(document.documentElement.clientHeight, window.innerHeight || 0)')).to eq(1302 - CHROMEBROWSER_UICHROME_HEIGHT)
    end
  end

  context "Chrome browser, Android tablet agent, landscape orientation" do
    let(:device_key) { :android_phone }
    let(:device) { devices[device_key] }
    let(:orientation) { :landscape }
    let(:driver) do
      Webdriver::UserAgent.driver(
        browser: :chrome,
        agent: device_key,
        orientation: orientation
      )
    end
    let(:browser) { "chrome" }
    let(:agent_match) { 'Android' }

    it_behaves_like "browser driver"
    it_behaves_like "chrome size"
  end

  context "Firefox browser, desktop agent, landscape orientation" do
    let(:device_key) { :desktop }
    let(:device) { devices[device_key] }
    let(:orientation) { :landscape }
    let(:driver) do
      Webdriver::UserAgent.driver(
        browser: :firefox,
        agent: device_key,
        orientation: orientation
      )
    end
    let(:browser) { "firefox" }
    let(:agent_match) { 'Mac OS' }

    it_behaves_like "browser driver"
    it_behaves_like "firefox size"
  end

  context "random agent" do
    context "no specified browser" do
      let(:device_key) { :random }
      let(:driver) { Webdriver::UserAgent.driver(agent: device_key) }
      let(:browser) { :firefox }

      it_behaves_like "random browser driver"
    end

    context "chrome browser" do
      let(:device_key) { :random }
      let(:browser) { :chrome }
      let(:driver) do
        Webdriver::UserAgent.driver(browser: browser, agent: device_key)
      end

      it_behaves_like "random browser driver"
    end
  end

  context "existing firefox profile" do
    let(:device) { devices[:iphone] }
    let(:profile) do
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile["intl.accept_languages"] = "es-MX"
      profile
    end
    let(:options) { Selenium::WebDriver::Firefox::Options.new(profile: profile) }
    let(:browser) { :firefox }
    let(:agent_match) { 'iPhone' }
    let(:orientation) { :portrait }
    let(:driver) { Webdriver::UserAgent.driver(browser: browser, options: options) }

    it_behaves_like "browser driver"
    it_behaves_like "firefox size"

    it "absorbs the options' profile" do
      expect(driver.execute_script("return (navigator.language || navigator.userLanguage)")).to include("es-MX")
    end
  end

  context "user-provided user agent string for firefox" do
    let(:browser) { :firefox }
    let(:user_agent) { "Mozilla/4.0 (compatible; MSIE 5.5b1; Mac_PowerPC)" }
    let(:driver) { Webdriver::UserAgent.driver(user_agent_string: user_agent) }

    it "can create a new webdriver driver" do
      expect("#{driver.browser}").to match(/#{Regexp.quote(browser.to_s)}/i)

      expect(driver.execute_script("return navigator.userAgent")).to include("Mac_PowerPC")
    end
  end

  context "user-provided accept language string for firefox" do
    let(:browser) { :firefox }
    let(:language) { "es-ES, es-MX;q=0.9, es;q=0.5, *;0.4" }
    let(:driver) { Webdriver::UserAgent.driver(accept_language_string: language) }

    it "can create a new webdriver driver" do
      expect("#{driver.browser}").to match(/#{Regexp.quote(browser.to_s)}/i)

      expect(driver.execute_script("return (navigator.language || navigator.userLanguage)")).to include("es-ES")
    end
  end

  context "user-provided accept language string for safari" do
    let(:browser) { :safari }
    let(:language) { "es-ES, es-MX;q=0.9, es;q=0.5, *;0.4" }
    let(:driver) {
      Webdriver::UserAgent.driver(
        browser: browser,
        accept_language_string: language
      )
    }

    it "can create a new webdriver driver" do
      expect("#{driver.browser}").to match(/#{Regexp.quote(browser.to_s)}/i)
    end
    
    pending("a stable, documented way to programmatically change Safari details") do
      expect(driver.execute_script("return (navigator.language || navigator.userLanguage)")).to include("es-es")
    end
  end

  context "user-provided viewport size and agent for firefox" do
    let(:browser) { :firefox }
    let(:device_key) { :iphone11 }
    let(:device) { devices[device_key] }
    let(:width) { 800 }
    let(:height) { 600 }
    let(:agent_match) { 'iPhone' }
    let(:orientation) { :portrait }
    let(:driver) {
      Webdriver::UserAgent.driver(
        viewport_width: "#{width}",
        viewport_height: height,
        agent: device_key
      )
    }

    it_behaves_like "browser driver"
    it "uses user-provided dimensions" do
    	expect(driver.execute_script(width_script)).to eq(width)
    	expect(driver.execute_script(height_script)).to eq(height - FIREFOXBROWSER_UICHROME_HEIGHT)
    end
  end

  context "user-provided nonsense viewport size for firefox" do
    let(:browser) { :firefox }
    let(:device_key) { :iphone8 }
    let(:device) { devices[device_key] }
    let(:width) { "xyz" }
    let(:agent_match) { 'iPhone' }
    let(:orientation) { :portrait }
    let(:driver) {
      Webdriver::UserAgent.driver(
        viewport_width: "#{width}",
        agent: device_key
      )
    }

    it_behaves_like "browser driver"
    it_behaves_like "firefox size"
  end

  context "portrait firefox iphone" do
    let(:browser) { :firefox }
    let(:device_key) { :iphone }
    let(:device) { devices[device_key] }
    let(:width) { "xyz" }
    let(:agent_match) { 'iPhone' }
    let(:orientation) { :portrait }
    let(:driver) {
      Webdriver::UserAgent.driver(
        agent: device_key,
        browser: browser,
        orientation: orientation
      )
    }

    it "can create a browser using the driver" do
      browser = Watir::Browser.new(driver)

      expect(browser).to be_a(Watir::Browser)
      expect(browser.url).to be_a(String)
    end
  end
end
