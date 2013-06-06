require 'selenium-webdriver'
require 'facets/hash/except'
require 'yaml'
require 'json'
require 'core_ext/symbol'

module Webdriver
  module UserAgent
    def self.driver options={} 
      options[:browser] ||= :firefox
      options[:agent] ||= :iphone
      options[:orientation] ||= :portrait

      user_agent_string = agent_string_for options[:agent]

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
      resize_inner_window(driver, *resolution_for(options[:agent], options[:orientation])) unless (options[:agent].downcase == :random)
      driver
    end

    def self.devices
      @devices ||= YAML.load_file File.expand_path("../device-info/devices.yaml", __FILE__)
    end

    def self.resolution_for device_name, orientation
      device = devices[device_name.downcase][orientation.downcase]
      [device[:width],device[:height]]
    end

    def self.agent_string_for device
      user_agent_string = device.downcase == :random ? random_user_agent : devices[device.downcase][:user_agent]
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

    def self.random_user_agent
      File.foreach(File.expand_path("../device-info/user_agents.txt", __FILE__)).each_with_index.reduce(nil) { |picked,pair| 
      rand < 1.0/(1+pair[1]) ? pair[0] : picked }
    end

  end
end
