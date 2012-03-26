require 'selenium-webdriver'
require 'facets/hash/except'

module UserAgent
  def self.driver_for options={} 
    options[:browser] ||= :firefox
    options[:agent] ||= :iphone
    options[:orientation] ||= :portrait
    
    if options[:browser] == :firefox
      options[:profile] ||= Selenium::WebDriver::Firefox::Profile.new
      options[:profile]['general.useragent.override'] = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_2 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8H7 Safari/6533.18.5"
    end
    driver = Selenium::WebDriver.for options[:browser], options.except(:browser, :agent, :orientation)
    resize_inner_window driver, 320, 356
    driver
  end

  private

  def self.resize_inner_window driver, width, height
    if driver.browser == :firefox or :chrome
      driver.execute_script("window.open('#{driver.current_url}','_blank');")
        #{}'width=#{width},height=#{height}');")
      driver.close
      driver.switch_to.window driver.window_handles.first
    end
    driver.execute_script("window.innerWidth = #{width}; window.innerHeight = #{height};")
  end
end