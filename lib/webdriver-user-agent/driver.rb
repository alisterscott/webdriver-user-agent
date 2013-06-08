require 'yaml'
require 'json'
require 'selenium-webdriver'
require 'facets/hash/except'
require 'webdriver-user-agent/core_ext/symbol'
require 'webdriver-user-agent/browser_options'

module Webdriver
  module UserAgent
    class Driver
      include Singleton
      
      def for(opts)
        user_agent_string = agent_string_for opts[:agent]
        options = BrowserOptions.new(opts, user_agent_string)

        driver = Selenium::WebDriver.for options.browser, options.browser_options
        resize_inner_window(driver, *resolution_for(options.agent, options.orientation)) unless (options.agent.downcase == :random)
        driver
      end

      def devices
        YAML.load_file File.expand_path("../../device-info/devices.yaml", __FILE__)
      end


      def resolution_for device_name, orientation
        device = devices[device_name.downcase][orientation.downcase]
        [device[:width],device[:height]]
      end

      def agent_string_for(device)
        device = (device ? device.downcase : :iphone)
        user_agent_string = device == :random ? random_user_agent : devices[device][:user_agent]
        raise "Unsupported user agent: '#{options[:agent]}'." unless user_agent_string
        user_agent_string 
      end

      private

      def random_user_agent
        File.foreach(File.expand_path("../../device-info/user_agents.txt", __FILE__)).each_with_index.reduce(nil) { |picked,pair| 
          rand < 1.0/(1+pair[1]) ? pair[0] : picked }
      end

      def resize_inner_window driver, width, height
        if driver.browser == :firefox or :chrome
          driver.execute_script("window.open(#{driver.current_url.to_json},'_blank');")
          driver.close
          driver.switch_to.window driver.window_handles.first
        end
        driver.execute_script("window.innerWidth = #{width}; window.innerHeight = #{height};")
      end

    end
  end
end
