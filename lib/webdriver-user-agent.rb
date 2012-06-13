require 'selenium-webdriver'
require 'facets/hash/except'
require 'yaml'
require 'json'

module UserAgent
  def self.driver options={} 
    options[:browser] ||= :firefox
    options[:agent] ||= :iphone
    options[:orientation] ||= :portrait
    
    user_agent_string = agent_string_for options[:agent]
    device_resolution = resolution_for options[:agent], options[:orientation]

    case options[:browser]
      when :firefox
        options[:profile] ||= Selenium::WebDriver::Firefox::Profile.new
        options[:profile]['general.useragent.override'] = user_agent_string
      when :chrome
        options[:switches] ||= []
        options[:switches] << "--user-agent=#{user_agent_string}"
      else
        raise "WebDriver UserAgent currently only supports :firefox and :chrome."
    end
    driver = Selenium::WebDriver.for options[:browser], options.except(:browser, :agent, :orientation)
    resize_inner_window driver, *device_resolution
    driver
  end

  def self.devices
    @devices ||= YAML.load_file File.expand_path("../device-info/devices.yaml", __FILE__)
  end

  def self.resolution_for device_name, orientation
    device = devices[downcase_sym device_name][downcase_sym orientation]
    [device[:width],device[:height]]
  end

  def self.agent_string_for device
    user_agent_string = devices[downcase_sym device][:user_agent]
    raise "Unsupported user agent: '#{options[:agent]}'." unless user_agent_string
    user_agent_string 
  end 

  private

  def self.resize_inner_window driver, width, height
    if driver.browser == :firefox or :chrome
      driver.execute_script("window.open(#{driver.current_url.to_json},'_blank');")
      driver.close
      driver.switch_to.window driver.window_handles.first
    end
    driver.execute_script("window.innerWidth = #{width}; window.innerHeight = #{height};")
  end

  def self.downcase_sym sym
    sym.to_s.downcase.to_sym #to support ruby 1.8.x
  end
end